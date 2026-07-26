---
name: tts
description: Turn text into spoken audio using the OpenAI audio API - choose from 13 voices, adjust speed, and steer tone or emotion. Use whenever Byron asks to hear something read aloud, wants an mp3 or voiceover generated, asks to "say this", "read this out", "convert to audio/speech", "make an audio file", or wants to rehearse a script or presentation by listening to it. Also use when he asks to change the voice, make it faster or slower, or try different tones on audio that was already generated. Covers which speed levers actually work (measured), the 13 available voices, and the gpt-audio-mini path for genuinely re-performed fast speech.
---

# Text to speech

Render text to audio via the OpenAI audio API. Auth is Doppler (`global` / `home`,
key `OPENAI_API_KEY`); the script handles this by re-execing itself under
`doppler run`, so no manual credential steps are needed.

## The script

`scripts/say.sh` wraps everything. Run `say.sh --help` for the full interface.

```sh
S=~/.claude/skills/tts/scripts/say.sh

# Single render
"$S" --text "Hello there." --voice echo --speed 1.15 --tone "warm and conversational" --open

# Same text across several voices, so Byron can A/B fairly
"$S" --text "..." --compare "echo,cedar,marin,onyx" --name pick

# Same text at several speeds, to find the intelligibility ceiling
"$S" --text "..." --ladder "1.0,1.15,1.3,1.5" --name pace

# Long text: one file per paragraph plus a joined full version (needs ffmpeg)
"$S" --file script.txt --split --voice echo --name talk
```

Output defaults to `~/Downloads/tts`. Pass `--open` to reveal it in Finder. Do not
write audio into a job temp dir; it gets deleted.

## Voices

13 on `gpt-4o-mini-tts`: `alloy, ash, ballad, coral, echo, fable, onyx, nova, sage,
shimmer, verse, cedar, marin`.

`cedar` and `marin` are the newest and generally the most natural sounding. Byron's
established preference for interview rehearsal is **echo** with a bright, energetic
tone. `tts-1` and `tts-1-hd` reject ballad, verse, cedar, and marin.

## Speed: what actually works

This was measured empirically with 3x replication. Do not re-derive it.

| Lever | Effect |
| --- | --- |
| `--speed` param (0.25-4.0) | **Works.** The only reliable lever on the TTS endpoint. |
| Prompt wording for pace | **Does not work.** 1.0-1.08x across 10 instruction strategies. |
| Stripping punctuation from input | **Does not work.** 1.05x, within noise. |
| Pace prompt on `gpt-audio-mini` | **Works,** ~1.2x, and sounds re-performed. |

Notes on `--speed`: gains plateau past ~3.0x (4.0x buys only 15% over 3.0x), and
past roughly 1.3x it starts sounding compressed rather than genuinely fast. For
spoken delivery Byron will actually use, 1.15-1.3x is the practical band.

When testing pace changes, always render 2-3 reps before believing a result.
Run-to-run duration variance is around 1-2s on a 15s clip, which is large enough to
manufacture a convincing false effect from a single sample.

## Tone

`--tone` maps to the API's `instructions` field and steers delivery well: "warm and
conversational", "calm and low", "bright and engaged", "thoughtful, with natural
pauses". It does **not** steer pace, and it does **not** steer accent. All voices
are American; a New Zealand accent is not achievable.

Only `gpt-4o-mini-tts` honours `instructions`. `tts-1` and `tts-1-hd` accept the
field and return 200 while silently ignoring it, so switching model to save cost
will quietly drop tone direction with no error.

## Genuinely fast speech: gpt-audio-mini

For fast delivery that sounds re-performed rather than sped up, use
`gpt-audio-mini` on `/v1/chat/completions` (not the speech endpoint, which 404s for
that model):

```sh
jq -n --arg s "$SYSTEM" --arg t "$TEXT" '{
  model:"gpt-audio-mini", modalities:["text","audio"],
  audio:{voice:"echo", format:"mp3"},
  messages:[{role:"system",content:$s},
            {role:"user",content:("Read this aloud exactly as written, verbatim, adding nothing: " + $t)}]
}' | curl -s https://api.openai.com/v1/chat/completions \
      -H "Authorization: Bearer $OPENAI_API_KEY" -H "Content-Type: application/json" -d @- \
  | tee /tmp/res.json | jq -r '.choices[0].message.audio.data' | base64 -d > out.mp3
```

Caps at ~1.2x; a more extreme prompt does not go faster. There is no `speed`
param on this endpoint, so the two levers cannot be stacked. The full `gpt-audio`
model is worse at this than the mini.

**This model is an LLM, so it can paraphrase.** Always verify the returned
transcript (`.choices[0].message.audio.transcript`) against the source, comparing
word counts, before handing the audio over.

## Gotchas

- macOS ships bash 3.2: no `declare -A`. Use a `case` function instead.
- Measure duration with `afinfo FILE | grep 'estimated duration'`.
- The speech endpoint caps input around 4096 characters. Use `--split` for longer.
- Render parts in parallel with `&` / `wait`; serial rendering is needlessly slow.
- When offering Byron a choice of voices, render the **same** text in each so the
  comparison is apples to apples, then let him pick before doing the full render.
