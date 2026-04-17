# whisper-wrapper - Windows PowerShell wrapper for whisper.cpp
# Provides NVIDIA CUDA GPU-accelerated transcription with automatic audio normalization

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$InputFile,

    [Parameter(Position=1)]
    [string]$Lang = "en"
)

$OutDir   = "$HOME\Documents\Laroy"
$TmpDir   = $env:TEMP
$WhisperCli = "$HOME\whisper.cpp\build\bin\Release\whisper-cli.exe"
$Model    = "$HOME\whisper.cpp\models\ggml-medium.en.bin"

if (-not (Test-Path $InputFile)) {
    Write-Error "File not found: $InputFile"
    exit 1
}

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

$Base    = [System.IO.Path]::GetFileNameWithoutExtension($InputFile)
$Ext     = [System.IO.Path]::GetExtension($InputFile).TrimStart('.').ToLower()
$TmpWav  = "$TmpDir\${Base}_whisper.wav"

if ($Ext -eq "wav") {
    $TmpWav = $InputFile
} else {
    & ffmpeg -y -i $InputFile -ar 16000 -ac 1 -c:a pcm_s16le $TmpWav 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Error "ffmpeg conversion failed"
        exit 1
    }
}

& $WhisperCli `
    -m $Model `
    -l $Lang `
    -nt `
    -t 4 `
    -otxt `
    -of "$OutDir\$Base" `
    $TmpWav

# Rename .txt to .md
$TxtFile = "$OutDir\$Base.txt"
$MdFile  = "$OutDir\$Base.md"
if (Test-Path $TxtFile) {
    Move-Item -Force $TxtFile $MdFile
}

if ($TmpWav -ne $InputFile -and (Test-Path $TmpWav)) {
    Remove-Item $TmpWav
}
