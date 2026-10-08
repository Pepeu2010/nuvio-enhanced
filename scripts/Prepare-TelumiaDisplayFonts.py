"""Deterministic static Manrope instances for the native Compose clients; keeps the licensed VF source."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil

import fontTools
from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "repos/desktop/composeApp/src/commonMain/composeResources/font/manrope_variable.ttf"
SOURCE_SHA256 = "3ae11c49db0455a3cc33e37d380f20fdb8c7f8b41dc07625c177e3d87a9d6ae6"
WEIGHTS = {"regular": 400, "medium": 500, "semibold": 600, "bold": 700}


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def prepare(install):
    if fontTools.__version__ != "4.59.0":
        raise RuntimeError("Use the isolated pinned fontTools 4.59.0 runtime")
    if digest(SOURCE) != SOURCE_SHA256:
        raise RuntimeError("The licensed pinned source font changed")
    output = ROOT / "artifacts/telumia-static-manrope/fonts"
    output.mkdir(parents=True, exist_ok=True)
    records = []
    for name, weight in WEIGHTS.items():
        with TTFont(SOURCE, recalcTimestamp=False) as original:
            instance = instantiateVariableFont(original, {"wght": weight}, inplace=False, updateFontNames=True)
            instance.recalcTimestamp = False
            if "fvar" in instance or instance["OS/2"].usWeightClass != weight:
                raise RuntimeError(f"Incorrect static weight {weight}")
            filename = f"manrope_{name}.ttf"
            path = output / filename
            instance.save(path)
            instance.close()
        records.append({"file": filename, "weight": weight, "bytes": path.stat().st_size, "sha256": digest(path)})
        if install:
            for relative in ("repos/desktop/composeApp/src/commonMain/composeResources/font",
                             "repos/tv/app/src/main/res/font"):
                shutil.copyfile(path, ROOT / relative / filename)
    manifest = {"sourceRepository": "https://github.com/google/fonts", "sourceCommit": "b31870aff700ab7a1d74fa0c6887d95beb9e0037",
                "sourceFontSha256": SOURCE_SHA256, "sourceDefaultWeight": 200, "license": "SIL Open Font License 1.1",
                "tool": "fontTools 4.59.0 varLib.instancer", "timestampPolicy": "Preserve source timestamps; no generation-time stamp",
                "scope": "Static native display weights; original variable font remains available for the HTML player. No whole-interface or device-performance completion claim.",
                "fonts": records}
    (ROOT / "docs/telumia-static-manrope.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"prepared": len(records), "installed": install, "fonts": records}))


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--install", action="store_true", help="Copy instances into the two existing resource trees after active builds finish")
    prepare(parser.parse_args().install)
