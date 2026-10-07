[CmdletBinding()]
param([ValidatePattern('^[a-z0-9-]+$')][string]$Label = 'profile-studio-runtime')
$ErrorActionPreference = 'Stop'
$workspace = Split-Path $PSScriptRoot -Parent
$checkout = Join-Path $workspace 'repos/desktop'
$runtime = Join-Path $checkout 'composeApp/build/compose/tmp/main/runtime'
$jar = Join-Path $checkout 'composeApp/build/libs/composeApp-desktop.jar'
$output = Join-Path $workspace "artifacts/$Label"
if (Test-Path -LiteralPath $output) { throw 'Use a new label; existing runtime evidence will not be replaced.' }
$jdk = Get-ChildItem (Join-Path $env:USERPROFILE '.gradle/jdks') -Directory |
    Where-Object { $_.Name -match '-17-' -and (Test-Path (Join-Path $_.FullName 'bin/javac.exe')) } | Select-Object -First 1
if (-not $jdk) { throw 'Build JDK 17 unavailable.' }
$stdlib = Get-ChildItem (Join-Path $env:USERPROFILE '.gradle/caches/modules-2/files-2.1/org.jetbrains.kotlin/kotlin-stdlib') -Filter '*.jar' -Recurse |
    Where-Object { $_.Name -match '^kotlin-stdlib-[0-9].*\.jar$' } | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (-not $stdlib -or -not (Test-Path $jar) -or -not (Test-Path (Join-Path $runtime 'lib/modules'))) { throw 'Built avatar JAR, runtime or stdlib unavailable.' }
New-Item -ItemType Directory -Path $output | Out-Null
# Compose strips command-line launchers. Add only java.exe to an isolated byte-for-byte runtime copy.
$clone = Join-Path $output 'runtime'
Copy-Item -LiteralPath $runtime -Destination $clone -Recurse
Copy-Item -LiteralPath (Join-Path $jdk.FullName 'bin/java.exe') -Destination (Join-Path $clone 'bin/java.exe')
foreach ($file in @('lib/modules','bin/java.dll','bin/jli.dll','bin/server/jvm.dll','bin/awt.dll','bin/javajpeg.dll')) {
    if ((Get-FileHash (Join-Path $runtime $file)).Hash -ne (Get-FileHash (Join-Path $clone $file)).Hash) { throw "Runtime copy differs: $file" }
}
$source = @'
import java.awt.Color;
import java.awt.image.BufferedImage;
import java.io.*;
import java.lang.reflect.*;
import java.util.Map;
import javax.imageio.ImageIO;
public final class AvatarRuntimeSmoke {
    public static void main(String[] args) throws Exception {
        BufferedImage image = new BufferedImage(200, 100, BufferedImage.TYPE_INT_RGB);
        var graphics = image.createGraphics();
        try { graphics.setColor(Color.RED); graphics.fillRect(0,0,100,100);
              graphics.setColor(Color.BLUE); graphics.fillRect(100,0,100,100); }
        finally { graphics.dispose(); }
        ByteArrayOutputStream encoded = new ByteArrayOutputStream();
        if (!ImageIO.write(image, "png", encoded)) throw new AssertionError("PNG encoder missing");
        Class<?> pipelineType = Class.forName("com.nuvio.app.features.profiles.AvatarRasterPipeline");
        Object pipeline = pipelineType.getField("INSTANCE").get(null);
        Object source = pipelineType.getMethod("decode", byte[].class).invoke(pipeline, encoded.toByteArray());
        Class<?> cropType = Class.forName("com.nuvio.app.features.profiles.AvatarCrop");
        Object crop = cropType.getConstructor(float.class,float.class,float.class).newInstance(1f,.5f,2f);
        Map<?,?> variants = (Map<?,?>) pipelineType.getMethod("variants",source.getClass(),cropType).invoke(pipeline,source,crop);
        if (variants.size() != 4) throw new AssertionError("Variants missing");
        for (int size : new int[]{64,128,256,512}) {
            BufferedImage result = ImageIO.read(new ByteArrayInputStream((byte[]) variants.get(size)));
            if (result == null || result.getWidth()!=size || result.getHeight()!=size || result.getRGB(size/2,size/2)!=Color.BLUE.getRGB())
                throw new AssertionError("Incorrect actual avatar crop: " + size);
        }
        ByteArrayOutputStream jpeg = new ByteArrayOutputStream();
        if (!ImageIO.write(image,"jpeg",jpeg)) throw new AssertionError("JPEG encoder missing");
        pipelineType.getMethod("decode",byte[].class).invoke(pipeline,jpeg.toByteArray());
        System.out.println("PASS: actual avatar decoder and four cropped variants on packaged runtime modules");
    }
}
'@
$sourceFile = Join-Path $output 'AvatarRuntimeSmoke.java'
[IO.File]::WriteAllText($sourceFile, $source, [Text.UTF8Encoding]::new($false))
$compile = & (Join-Path $jdk.FullName 'bin/javac.exe') -d $output $sourceFile 2>&1
if ($LASTEXITCODE -ne 0) { $compile | Set-Content (Join-Path $output 'compile.log'); throw 'Runtime smoke harness compilation failed.' }
$classpath = "$output;$jar;$($stdlib.FullName)"
$result = & (Join-Path $clone 'bin/java.exe') '-Djava.awt.headless=true' '-cp' $classpath 'AvatarRuntimeSmoke' 2>&1
$exit = $LASTEXITCODE
$result | Set-Content (Join-Path $output 'runtime.log') -Encoding utf8
if ($exit -ne 0 -or $result -notmatch '^PASS: actual avatar decoder') { throw 'Actual avatar pipeline failed on packaged runtime modules.' }
[ordered]@{
    recordedAtUtc=[DateTime]::UtcNow.ToString('o');status='passed';exitCode=$exit
    sourceCommit=(git -C $checkout rev-parse HEAD).Trim()
    trackedChanges=@(git -C $checkout status --porcelain --untracked-files=no)
    jarSha256=(Get-FileHash $jar).Hash.ToLowerInvariant()
    runtimeModulesSha256=(Get-FileHash (Join-Path $runtime 'lib/modules')).Hash.ToLowerInvariant()
    scope='Production AvatarRasterPipeline reflection, PNG/JPEG decoding and 64/128/256/512 crop output under an unchanged copy of packaged runtime modules; build JDK java.exe added only to the isolated copy; no installer launch, clipboard or OS file picker claim'
} | ConvertTo-Json -Depth 4 | Set-Content (Join-Path $output 'result.json') -Encoding utf8
Write-Output 'Avatar decoder and four variants passed on packaged runtime modules.'
