#!/usr/bin/env python
"""whisper.cpp segments (JSON) + pyannote speakers -> markdown transcript with speaker labels."""
import json, os, sys
import soundfile as sf, torch
from pyannote.audio import Pipeline

wav, seg_json, out_md = sys.argv[1:4]
token = os.environ.get("HF_TOKEN") or open(os.path.expanduser("~/.cache/huggingface/token")).read().strip()

pipe = Pipeline.from_pretrained("pyannote/speaker-diarization-3.1", token=token).to(torch.device("cuda"))
audio, sr = sf.read(wav, dtype="float32")
turns = [(t.start, t.end, s) for t, _, s in
         pipe({"waveform": torch.from_numpy(audio)[None], "sample_rate": sr}).itertracks(yield_label=True)]

def speaker(a, b):  # speaker with most overlap in [a,b]
    best = max(turns, key=lambda t: max(0, min(b, t[1]) - max(a, t[0])), default=None)
    return best[2] if best and min(b, best[1]) - max(a, best[0]) > 0 else "UNKNOWN"

lines, cur = [], None
for s in json.load(open(seg_json))["transcription"]:
    a, b = s["offsets"]["from"] / 1000, s["offsets"]["to"] / 1000
    who, text = speaker(a, b), s["text"].strip()
    if who != cur:
        lines.append(f"\n**{who}** ({int(a//60):02d}:{int(a%60):02d}):")
        cur = who
    lines.append(text)
open(out_md, "w").write("\n".join(lines).strip() + "\n")
print(out_md)
