#!/usr/bin/env bash
# whisper-wrapper - Linux shell wrapper for whisper.cpp
# Provides Vulkan GPU-accelerated transcription with automatic audio normalization

whisper() {
  local in="$1"
  local lang="${2:-en}"
  local out_dir="$HOME/Documents/Laroy"
  local tmp_dir="/tmp"
  local base tmp_wav

  if [[ -z "$in" ]]; then
    echo "usage: whisper <audio-or-video-file> [language-code]"
    echo "  language-code: en (default), ru (Russian), etc."
    return 1
  fi

  mkdir -p "$out_dir"

  base="$(basename "$in")"
  base="${base%.*}"
  tmp_wav="$tmp_dir/${base}_whisper.wav"

  case "${in##*.}" in
    wav|WAV)
      tmp_wav="$in"
      ;;
    *)
      ffmpeg -y -i "$in" -ar 16000 -ac 1 -c:a pcm_s16le "$tmp_wav" \
        >/dev/null 2>&1 || {
          echo "ffmpeg conversion failed"
          return 1
        }
      ;;
  esac

  # ponytail: WHISPER_DIARIZE=1 -> tinydiarize (speaker turns only, en). Real labels need whisperX+pyannote.
  local model="$HOME/whisper.cpp/models/ggml-medium.en.bin" extra=()
  if [[ -n "$WHISPER_DIARIZE" ]]; then
    model="$HOME/whisper.cpp/models/ggml-small.en-tdrz.bin"; extra=(-tdrz)
  fi

  ~/whisper.cpp/build/bin/whisper-cli \
    -m "$model" "${extra[@]}" \
    -l "$lang" \
    -nt \
    -t 4 \
    -otxt \
    -of "$out_dir/$base" \
    "$tmp_wav"

  # Rename .txt to .md
  if [[ -f "$out_dir/$base.txt" ]]; then
    mv "$out_dir/$base.txt" "$out_dir/$base.md"
  fi

  if [[ "$tmp_wav" != "$in" ]]; then
    rm -f "$tmp_wav"
  fi
}

# whisperx: GPU transcription (Vulkan) + pyannote diarisation (ROCm) with speaker labels
whisperx() {
  local in="$1" lang="${2:-en}" dir; dir="$(dirname "${BASH_SOURCE[0]}")"
  local base; base="$(basename "${in%.*}")"
  local wav="/tmp/${base}_whisper.wav" out="$HOME/Documents/Laroy/$base"
  [[ -z "$in" ]] && { echo "usage: whisperx <audio-or-video-file> [language-code]"; return 1; }
  ffmpeg -y -i "$in" -ar 16000 -ac 1 -c:a pcm_s16le "$wav" >/dev/null 2>&1 || { echo "ffmpeg failed"; return 1; }
  ~/whisper.cpp/build/bin/whisper-cli -m "$HOME/whisper.cpp/models/ggml-medium.en.bin" -l "$lang" -t 4 \
    -oj -of "/tmp/$base" "$wav" >/dev/null &&
  "$dir/.venv/bin/python" "$dir/diarize.py" "$wav" "/tmp/$base.json" "$out.md"
  rm -f "$wav" "/tmp/$base.json"
}

[[ "${BASH_SOURCE[0]}" == "$0" ]] && whisper "$@"
