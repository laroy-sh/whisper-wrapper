#!/usr/bin/env zsh
# whisper-wrapper - macOS shell wrapper for whisper.cpp
# Provides GPU-accelerated transcription with automatic audio normalization

whisper() {
  local in="$1"
  local lang="${2:-en}"
  local out_dir="$HOME/Documents/Laroy"
  local tmp_dir="/private/var/tmp"
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

  ~/whisper.cpp/build/bin/whisper-cli \
    -m "$HOME/whisper.cpp/models/ggml-small.bin" \
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
