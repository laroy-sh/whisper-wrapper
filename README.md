# whisper-wrapper

A macOS shell wrapper around [whisper.cpp](https://github.com/ggerganov/whisper.cpp) that provides stable, GPU-accelerated transcription with automatic audio normalization and controlled file placement.

## Features

- 🚀 **GPU-accelerated** transcription using Apple Metal
- 🎵 **Automatic audio normalization** to whisper.cpp requirements (16kHz, mono, PCM)
- 🗂️ **Smart file management** - temporary files in `/private/var/tmp` (no cloud sync)
- 📝 **Clean output** - Markdown-compatible transcripts in `~/Documents/Laroy`
- 🧹 **Automatic cleanup** - no intermediate files left behind
- 💪 **Stable** - avoids Python/PyTorch instability issues

## Prerequisites

Before using this wrapper, you need to have [whisper.cpp](https://github.com/ggerganov/whisper.cpp) installed and compiled with Metal support.

### Install whisper.cpp

```bash
# Clone whisper.cpp
cd ~
git clone https://github.com/ggerganov/whisper.cpp.git
cd whisper.cpp

# Build with Metal support (Apple Silicon)
make clean
WHISPER_METAL=1 make -j

# The whisper-cli binary will be in: ~/whisper.cpp/build/bin/whisper-cli

# Download the small model (or choose another size)
bash ./models/download-ggml-model.sh small
```

### Install ffmpeg

```bash
brew install ffmpeg
```

## Installation

### Option 1: Source directly in ~/.zshrc

1. Clone this repository:
   ```bash
   git clone <repo-url> ~/Project/whisper
   ```

2. Add to your `~/.zshrc`:
   ```bash
   # Whisper transcription wrapper
   source ~/Project/whisper/whisper.sh
   ```

3. Reload your shell:
   ```bash
   source ~/.zshrc
   ```

### Option 2: Copy function to ~/.zshrc

Alternatively, you can copy the entire function from `whisper.sh` directly into your `~/.zshrc` file.

## Usage

```bash
whisper <audio-or-video-file>
```

### Examples

```bash
# Transcribe an OBS recording
whisper ~/Transcripts/meeting-2026-01-15.mkv

# Transcribe an audio file
whisper ~/Downloads/podcast.m4a

# Transcribe a WAV file
whisper ~/Audio/interview.wav
```

### Supported Input Formats

- Video: `.mkv`, `.mp4`, `.mov`, `.avi`
- Audio: `.m4a`, `.mp3`, `.wav`, `.flac`, `.ogg`
- Any format supported by ffmpeg

## How It Works

1. **Input handling** - Accepts any audio/video file path
2. **Temporary conversion** - Converts to 16kHz mono WAV in `/private/var/tmp` (avoids cloud sync)
3. **Transcription** - Uses `whisper-cli` from whisper.cpp with Metal GPU acceleration and the small model
4. **Output** - Generates transcript as `.txt` and automatically renames to `.md` in `~/Documents/Laroy`
5. **Cleanup** - Removes temporary WAV file

### Output Location

By default, transcripts are saved to:
```
~/Documents/Laroy/<filename>.md
```

To change this, edit the `out_dir` variable in `whisper.sh`:
```bash
local out_dir="$HOME/Documents/Laroy"  # Change this path
```

### Model Selection

The function uses the `small` model by default. To use a different model:

1. Download it: `bash ~/whisper.cpp/models/download-ggml-model.sh <model-name>`
2. Edit the model path in `whisper.sh`:
   ```bash
   -m "$HOME/whisper.cpp/models/ggml-small.bin"  # Change to ggml-medium.bin, etc.
   ```

Available models: `tiny`, `base`, `small`, `medium`, `large`

## Configuration

### Adjust Output Directory

Edit the `out_dir` variable:
```bash
local out_dir="$HOME/Documents/Laroy"
```

### Adjust Thread Count

Change the `-t 4` parameter to match your CPU cores:
```bash
-t 8 \  # Use 8 threads
```

### Enable Timestamps

Remove the `-nt` flag to include timestamps in output.

## Troubleshooting

**"ffmpeg conversion failed"**
- Ensure ffmpeg is installed: `brew install ffmpeg`
- Check that the input file exists and is readable

**"Model not found"**
- Download the model: `bash ~/whisper.cpp/models/download-ggml-model.sh small`
- Verify the model path exists: `~/whisper.cpp/models/ggml-small.bin`
- Verify the whisper-cli binary exists: `~/whisper.cpp/build/bin/whisper-cli`

**Slow transcription**
- Ensure whisper.cpp was compiled with Metal: check for `WHISPER_METAL=1` in build
- Try a smaller model (`tiny` or `base`)

**Output file not created**
- Check that `~/Documents/Laroy` is writable
- Verify the output path exists: `mkdir -p ~/Documents/Laroy`

## Why This Wrapper?

This wrapper solves several common issues with whisper transcription on macOS:

1. **Stability** - whisper.cpp is more reliable than Python-based whisper implementations
2. **Performance** - Direct Metal acceleration without PyTorch overhead
3. **File Management** - Keeps cloud-synced directories clean by using system temp space
4. **Simplicity** - One command transcription without manual format conversion
5. **Reproducibility** - Consistent output location and format for downstream tools

## License

MIT License - See LICENSE file for details

## Contributing

Contributions welcome! Please open an issue or PR.

## Acknowledgments

- [whisper.cpp](https://github.com/ggerganov/whisper.cpp) by Georgi Gerganov
- [OpenAI Whisper](https://github.com/openai/whisper) model
