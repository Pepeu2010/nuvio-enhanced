"""Bounded decoder probe using the checked-in libmpv and an original generated AVI.

This is a test fixture, not an alternate player. It proves native frame capture and
decoder isolation only; JNI, application controls, remote sources and cache need
separate integration gates. ABI: mpv-player/mpv v0.41.0 include/mpv/client.h.
"""
import ctypes as c
import hashlib
import json
import os
from pathlib import Path
import re
import struct
import subprocess
import sys
import time


class Node(c.Structure):
    pass


class NodeList(c.Structure):
    _fields_ = [("num", c.c_int), ("values", c.POINTER(Node)), ("keys", c.POINTER(c.c_char_p))]


class ByteArray(c.Structure):
    _fields_ = [("data", c.c_void_p), ("size", c.c_size_t)]


class NodeValue(c.Union):
    _fields_ = [("string", c.c_char_p), ("flag", c.c_int), ("int64", c.c_int64),
                ("double", c.c_double), ("list", c.POINTER(NodeList)), ("ba", c.POINTER(ByteArray))]


Node._fields_ = [("u", NodeValue), ("format", c.c_int)]


class Event(c.Structure):
    _fields_ = [("id", c.c_int), ("error", c.c_int), ("userdata", c.c_uint64), ("data", c.c_void_p)]


def chunk(kind, payload):
    return kind + struct.pack("<I", len(payload)) + payload + (b"\0" if len(payload) % 2 else b"")


def original_avi(path):
    width, height, count, fps = 96, 54, 12, 2
    size = width * height * 3
    avih = struct.pack("<14I", 1_000_000 // fps, size * fps, 0, 0x10, count, 0, 1, size, width, height, 0, 0, 0, 0)
    strh = struct.pack("<4s4sIHHIIIIIIIIhhhh", b"vids", b"DIB ", 0, 0, 0, 0, 1, fps, 0, count, size, 0xFFFFFFFF, 0, 0, 0, width, height)
    strf = struct.pack("<IiiHHIIiiII", 40, width, height, 1, 24, 0, size, 0, 0, 0, 0)
    headers = chunk(b"LIST", b"hdrl" + chunk(b"avih", avih) + chunk(b"LIST", b"strl" + chunk(b"strh", strh) + chunk(b"strf", strf)))
    frames, index, offset = [], [], 4
    for frame in range(count):
        color = [frame + 2] * 3
        color[2 - frame // 4] = 255  # Every frame is distinct, grouped into red, green and blue scenes.
        payload = bytes(color) * (width * height)
        encoded = chunk(b"00db", payload)
        frames.append(encoded)
        index.append(struct.pack("<4sIII", b"00db", 0x10, offset, len(payload)))
        offset += len(encoded)
    body = b"AVI " + headers + chunk(b"LIST", b"movi" + b"".join(frames)) + chunk(b"idx1", b"".join(index))
    path.write_bytes(chunk(b"RIFF", body))


def main(label):
    if os.name != "nt" or not re.fullmatch(r"[a-z0-9-]+", label):
        raise ValueError("A Windows host and unique safe fixture label are required")
    workspace = Path(__file__).resolve().parent.parent
    output = workspace / "artifacts" / label
    output.mkdir(exist_ok=False)
    dll = workspace / "repos/desktop/composeApp/src/desktopMain/native/windows/runtime/libmpv-2.dll"
    fixture = output / "original-colors.avi"
    original_avi(fixture)
    report = {"status": "running", "sourceCommit": subprocess.check_output(["git", "-C", str(workspace / "repos/desktop"), "rev-parse", "HEAD"], text=True).strip(),
              "dllSha256": hashlib.sha256(dll.read_bytes()).hexdigest(), "fixtureSha256": hashlib.sha256(fixture.read_bytes()).hexdigest(), "frames": [],
              "scope": "Actual bundled libmpv C API, original local video, paused silent vo=null decoders. No JNI, application controls, account, remote media, HDR, cache or device performance proof."}
    handles = []
    with os.add_dll_directory(str(dll.parent)):
        api = c.CDLL(str(dll))
        api.mpv_create.restype = c.c_void_p
        api.mpv_set_option_string.argtypes = [c.c_void_p, c.c_char_p, c.c_char_p]
        api.mpv_initialize.argtypes = [c.c_void_p]
        api.mpv_command.argtypes = [c.c_void_p, c.POINTER(c.c_char_p)]
        api.mpv_command_ret.argtypes = [c.c_void_p, c.POINTER(c.c_char_p), c.POINTER(Node)]
        api.mpv_get_property.argtypes = [c.c_void_p, c.c_char_p, c.c_int, c.c_void_p]
        api.mpv_free_node_contents.argtypes = [c.POINTER(Node)]
        api.mpv_wait_event.argtypes = [c.c_void_p, c.c_double]
        api.mpv_wait_event.restype = c.POINTER(Event)
        api.mpv_terminate_destroy.argtypes = [c.c_void_p]

        def command(handle, *args):
            argv = (c.c_char_p * (len(args) + 1))(*[arg.encode("utf-8") for arg in args], None)
            if api.mpv_command(handle, argv) < 0:
                raise RuntimeError("Native fixture command failed")

        def position(handle, property_name=b"time-pos"):
            value = c.c_double()
            if api.mpv_get_property(handle, property_name, 5, c.byref(value)) < 0:
                raise RuntimeError("Actual native position is unavailable")
            return value.value

        def settled(handle):
            deadline = time.monotonic() + 4
            while time.monotonic() < deadline:
                event = api.mpv_wait_event(handle, 0.05).contents
                if event.id == 21:  # MPV_EVENT_PLAYBACK_RESTART: includes paused video display.
                    return
                if event.id == 7:  # MPV_EVENT_END_FILE
                    raise RuntimeError("Native fixture ended before producing a frame")
            raise TimeoutError("Native fixture did not settle in four seconds")

        def decoder():
            handle = api.mpv_create()
            if not handle:
                raise RuntimeError("No native decoder handle")
            handles.append(handle)
            for key, value in {"config": "no", "load-scripts": "no", "ytdl": "no", "terminal": "no", "pause": "yes",
                               "vo": "null", "audio": "no", "sub": "no", "hwdec": "no", "cache": "no", "demuxer-max-bytes": "1048576"}.items():
                if api.mpv_set_option_string(handle, key.encode(), value.encode()) < 0:
                    raise RuntimeError("A required native isolation option is unavailable: " + key)
            if api.mpv_initialize(handle) < 0:
                raise RuntimeError("Native decoder initialization failed")
            command(handle, "loadfile", str(fixture), "replace")
            settled(handle)
            return handle

        try:
            primary, preview = decoder(), decoder()
            command(primary, "seek", "0.75", "absolute+exact")
            settled(primary)
            before = position(primary)
            report["primaryPositionBeforeMs"] = round(before * 1000)
            for requested in [0.5, 2.0, 2.5, 3.0, 4.5, 0.5]:
                command(preview, "seek", str(requested), "absolute+exact")
                settled(preview)
                node = Node()
                args = (c.c_char_p * 4)(b"screenshot-raw", b"video", b"bgr0", None)
                try:
                    if api.mpv_command_ret(preview, args, c.byref(node)) < 0 or node.format != 8:
                        raise RuntimeError("The native video output cannot return a raw frame")
                    values = node.u.list.contents
                    if not 0 <= values.num <= 16:
                        raise RuntimeError("Unexpected native frame map")
                    data = {values.keys[i].decode(): values.values[i] for i in range(values.num)}
                    if any(data[key].format != 4 for key in ("w", "h", "stride")) or data["data"].format != 9:
                        raise RuntimeError("Unexpected native frame field types")
                    width, height, stride = (data[key].u.int64 for key in ("w", "h", "stride"))
                    raw = data["data"].u.ba.contents
                    if (width, height) != (96, 54) or stride < width * 4 or not stride * height <= raw.size <= 1_048_576:
                        raise RuntimeError("Native frame dimensions or buffer exceed the fixture bounds")
                    pixel = list(c.string_at(raw.data, 3))
                    actual = position(preview)
                    frame_index = round(actual * 2)
                    if not 0 <= frame_index < 12:
                        raise AssertionError("Decoded frame timestamp is outside the original fixture")
                    expected = [frame_index + 2] * 3
                    expected[2 - frame_index // 4] = 255
                    fixture_pts = (min(pixel) - 2) / 2
                    if pixel != expected or abs(actual - fixture_pts) > 0.001 or abs(actual - requested) > 0.501:
                        raise AssertionError("Decoded pixels or actual timestamp do not match the selected scene")
                    report["frames"].append({"requestedMs": round(requested * 1000), "actualMs": round(actual * 1000),
                                             "width": width, "height": height, "stride": stride, "bgr": pixel, "bytes": raw.size,
                                             "fixtureFramePtsMs": round(fixture_pts * 1000)})
                finally:
                    api.mpv_free_node_contents(c.byref(node))
            after = position(primary)
            report["primaryPositionAfterMs"] = round(after * 1000)
            if abs(before - after) > 0.001:
                raise AssertionError("The independent preview decoder changed the primary decoder position")
            report["status"] = "passed"
        except Exception as error:
            report.update(status="failed", failure=f"{type(error).__name__}: {error}")
            raise
        finally:
            for handle in reversed(handles):
                api.mpv_terminate_destroy(handle)
            (output / "qa.json").write_text(json.dumps(report, indent=2), encoding="utf-8")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main(sys.argv[1])
