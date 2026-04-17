# whisper-wrapper

A cross-platform shell wrapper around [whisper.cpp](https://github.com/ggerganov/whisper.cpp) for GPU-accelerated transcription with automatic audio normalization and clean Markdown output.

| Platform | Script | GPU Backend |
|----------|--------|-------------|
| macOS | `whisper-macos.sh` | Apple Metal |
| Linux | `whisper-linux.sh` | Vulkan (AMD / NVIDIA / Intel) |
| Windows | `whisper-windows.ps1` | Vulkan (AMD / NVIDIA / Intel) |

## Features

- **GPU-accelerated** — Metal on macOS, Vulkan on Linux/Windows
- **Automatic audio normalization** — converts any format to 16kHz mono PCM via ffmpeg
- **Smart file management** — temp files in system temp space (no cloud sync interference)
- **Clean output** — transcript saved as `.md` in `~/Documents/Laroy`
- **Automatic cleanup** — no intermediate files left behind
- **Stable** — avoids Python/PyTorch instability; runs the native C++ binary directly

---

## Prerequisites

### 1. Build whisper.cpp

```bash
cd ~
git clone https://github.com/ggml-org/whisper.cpp.git
cd whisper.cpp
```

**macOS (Metal):**
```bash
cmake -B build -DGGML_METAL=1
cmake --build build -j --config Release
```

**Linux (Vulkan):**
```bash
cmake -B build -DGGML_VULKAN=1
cmake --build build -j --config Release
```

**Windows (Vulkan) — PowerShell:**
```powershell
cmake -B build -DGGML_VULKAN=1
cmake --build build -j --config Release
```

### 2. Download a model

```bash
bash ~/whisper.cpp/models/download-ggml-model.sh medium.en
```

Available models: `tiny`, `tiny.en`, `base`, `base.en`, `small`, `small.en`, `medium`, `medium.en`, `large-v3`, `turbo`

The `.en` variants are faster and more accurate for English-only content.

### 3. Install ffmpeg

| Platform | Command |
|----------|---------|
| macOS | `brew install ffmpeg` |
| Linux (Debian/Ubuntu) | `sudo apt install ffmpeg` |
| Windows | `winget install ffmpeg` or [ffmpeg.org](https://ffmpeg.org/download.html) |

---

## Installation

### macOS / Linux

Add to your shell config (`~/.zshrc` or `~/.bashrc`):

```bash
source ~/path/to/whisper-wrapper/whisper-macos.sh   # macOS
source ~/path/to/whisper-wrapper/whisper-linux.sh   # Linux
```

Reload: `source ~/.zshrc`

### Windows

Run directly:
```powershell
.\whisper-windows.ps1 "C:\path\to\video.mp4"
```

Or add the folder to your `$PROFILE` for a persistent `whisper` alias.

---

## Usage

```bash
whisper <audio-or-video-file> [language-code]
```

### Examples

```bash
# Transcribe a lecture recording
whisper ~/Downloads/stanford-lecture.mp4

# Transcribe with a specific language
whisper ~/Downloads/interview.m4a ru

# Transcribe an audio file
whisper ~/Downloads/podcast.flac
```

**Windows:**
```powershell
.\whisper-windows.ps1 "C:\Users\you\Downloads\lecture.mp4"
.\whisper-windows.ps1 "C:\Users\you\Downloads\interview.m4a" ru
```

### Supported Input Formats

Any format supported by ffmpeg: `.mp4`, `.mkv`, `.mov`, `.avi`, `.m4a`, `.mp3`, `.wav`, `.flac`, `.ogg`, and more.

---

## Output

Transcripts are saved to:
```
~/Documents/Laroy/<filename>.md
```

To change the output directory, edit the `out_dir` variable in the relevant script.

---

## Configuration

### Model

Edit the `-m` flag to point to a different model:
```bash
-m "$HOME/whisper.cpp/models/ggml-large-v3.bin"
```

### Thread count

Change `-t 4` to match your CPU core count.

### Timestamps

Remove the `-nt` flag to include timestamps in the output.

---

## Troubleshooting

**"ffmpeg conversion failed"** — verify ffmpeg is installed and the input file exists.

**"No such file: whisper-cli"** — verify whisper.cpp was built successfully: `ls ~/whisper.cpp/build/bin/`.

**GPU not detected (Linux/Windows)** — confirm the Vulkan build: check the startup log for `ggml_vulkan: Found N Vulkan devices`. If empty, install Vulkan drivers (`mesa-vulkan-drivers` on Ubuntu, vendor driver on Windows).

**Slow transcription** — confirm GPU is being used (Vulkan device should appear in logs). Try a smaller model (`base.en`, `small.en`).

---

## License

MIT — see [LICENSE](LICENSE).

## Acknowledgments

- [whisper.cpp](https://github.com/ggml-org/whisper.cpp) by Georgi Gerganov
- [OpenAI Whisper](https://github.com/openai/whisper) model
