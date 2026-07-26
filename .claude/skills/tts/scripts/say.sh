#!/usr/bin/env bash
# Render text to speech via the OpenAI audio API.
# Auth: re-execs itself under `doppler run` if OPENAI_API_KEY is not already set.
# bash 3.2 compatible (macOS default) - no associative arrays.
set -uo pipefail

VOICES="alloy ash ballad coral echo fable onyx nova sage shimmer verse cedar marin"
MODEL="gpt-4o-mini-tts"
VOICE="echo"
SPEED=""
TONE=""
TEXT=""
FILE=""
OUTDIR="$HOME/Downloads/tts"
NAME="speech"
DO_OPEN=0
MODE="single"
LIST_VOICES=0
MAX_CHARS=4000

# Preserve argv before the parse loop consumes it - the doppler re-exec below
# needs the original arguments, not the shifted-empty remainder.
ORIG_ARGS=("$@")

usage() {
  cat <<'EOF'
say.sh - render text to speech (OpenAI)

USAGE
  say.sh --text "..."  [options]
  say.sh --file in.txt [options]
  say.sh --voices

OPTIONS
  --text TEXT       Text to speak.
  --file PATH       Read text from a file.
  --voice NAME      Voice (default: echo). See --voices.
  --speed N         0.25-4.0. Omit for natural pace. This is the ONLY
                    reliable speed lever on the TTS endpoint.
  --tone TEXT       Tone/emotion instruction, e.g. "warm and conversational".
                    Steers delivery but NOT pace.
  --model NAME      gpt-4o-mini-tts (default) | tts-1 | tts-1-hd
  --out DIR         Output dir (default: ~/Downloads/tts)
  --name BASE       Base filename (default: speech)
  --compare LIST    Comma-separated voices; renders the same text in each.
  --ladder LIST     Comma-separated speeds; renders the same text at each.
  --split           One file per paragraph (blank-line separated) plus a
                    joined full version.
  --open            Open the output dir when done.
  --voices          Print available voices and exit.

NOTES
  Prompting for PACE does not work on the TTS endpoint (measured 1.0-1.08x).
  Use --speed. For genuinely re-performed fast speech see the skill's
  gpt-audio-mini section - that path caps at ~1.2x and needs verbatim checking.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --text) TEXT="$2"; shift 2 ;;
    --file) FILE="$2"; shift 2 ;;
    --voice) VOICE="$2"; shift 2 ;;
    --speed) SPEED="$2"; shift 2 ;;
    --tone) TONE="$2"; shift 2 ;;
    --model) MODEL="$2"; shift 2 ;;
    --out) OUTDIR="$2"; shift 2 ;;
    --name) NAME="$2"; shift 2 ;;
    --compare) MODE="compare"; LIST="$2"; shift 2 ;;
    --ladder) MODE="ladder"; LIST="$2"; shift 2 ;;
    --split) MODE="split"; shift ;;
    --open) DO_OPEN=1; shift ;;
    --voices) LIST_VOICES=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [ "$LIST_VOICES" -eq 1 ]; then
  echo "$VOICES" | tr ' ' '\n'
  echo
  echo "note: tts-1 / tts-1-hd reject ballad, verse, cedar, marin"
  exit 0
fi

# Re-exec under doppler if the key is not in the environment.
if [ -z "${OPENAI_API_KEY:-}" ]; then
  command -v doppler >/dev/null || { echo "error: OPENAI_API_KEY unset and doppler not found" >&2; exit 1; }
  exec doppler run --project global --config home -- "$0" ${ORIG_ARGS[@]+"${ORIG_ARGS[@]}"}
fi

for bin in jq curl; do
  command -v "$bin" >/dev/null || { echo "error: $bin not found" >&2; exit 1; }
done

[ -n "$FILE" ] && TEXT="$(cat "$FILE")"
[ -z "$TEXT" ] && { echo "error: no text (use --text or --file)" >&2; usage >&2; exit 2; }

mkdir -p "$OUTDIR" || exit 1

duration_of() {
  if command -v afinfo >/dev/null; then
    afinfo "$1" 2>/dev/null | grep -o 'estimated duration: [0-9.]*' | grep -o '[0-9.]*' | head -1
  fi
}

# render <outfile> <voice> <speed> <text>
render() {
  local out="$1" voice="$2" speed="$3" text="$4"
  local req; req="$(mktemp)"
  if [ -n "$speed" ]; then
    jq -n --arg m "$MODEL" --arg v "$voice" --arg i "$TONE" --arg t "$text" --argjson s "$speed" \
      '{model:$m,voice:$v,input:$t,response_format:"mp3",speed:$s}
       + (if $i == "" then {} else {instructions:$i} end)' > "$req"
  else
    jq -n --arg m "$MODEL" --arg v "$voice" --arg i "$TONE" --arg t "$text" \
      '{model:$m,voice:$v,input:$t,response_format:"mp3"}
       + (if $i == "" then {} else {instructions:$i} end)' > "$req"
  fi
  local code
  code=$(curl -s -w '%{http_code}' -o "$out" https://api.openai.com/v1/audio/speech \
    -H "Authorization: Bearer $OPENAI_API_KEY" -H "Content-Type: application/json" -d @"$req")
  rm -f "$req"
  if [ "$code" != "200" ]; then
    echo "FAIL $(basename "$out") http=$code: $(jq -r '.error.message // "?"' < "$out" 2>/dev/null | head -c 160)" >&2
    rm -f "$out"
    return 1
  fi
  printf '%-44s %ss\n' "$(basename "$out")" "$(duration_of "$out")"
}

if [ ${#TEXT} -gt $MAX_CHARS ] && [ "$MODE" != "split" ]; then
  echo "warning: text is ${#TEXT} chars; endpoint limit is ~4096. Consider --split." >&2
fi

case "$MODE" in
  single)
    render "$OUTDIR/$NAME.mp3" "$VOICE" "$SPEED" "$TEXT"
    ;;
  compare)
    for v in $(echo "$LIST" | tr ',' ' '); do
      render "$OUTDIR/${NAME}_${v}.mp3" "$v" "$SPEED" "$TEXT" &
    done
    wait
    ;;
  ladder)
    for s in $(echo "$LIST" | tr ',' ' '); do
      render "$OUTDIR/${NAME}_${s}x.mp3" "$VOICE" "$s" "$TEXT" &
    done
    wait
    ;;
  split)
    # Split on blank lines into paragraph parts, render in parallel, then join.
    tmpd="$(mktemp -d)"
    printf '%s\n' "$TEXT" | awk -v d="$tmpd" '
      BEGIN{n=0; f=sprintf("%s/part_%02d.txt", d, n)}
      /^[[:space:]]*$/ { if (seen) { n++; f=sprintf("%s/part_%02d.txt", d, n); seen=0 } ; next }
      { print >> f; seen=1 }'
    i=0
    for p in "$tmpd"/part_*.txt; do
      [ -s "$p" ] || continue
      i=$((i+1))
      render "$OUTDIR/${NAME}_part$(printf '%02d' "$i").mp3" "$VOICE" "$SPEED" "$(cat "$p")" &
    done
    wait
    rm -rf "$tmpd"
    if command -v ffmpeg >/dev/null; then
      ls "$OUTDIR/${NAME}_part"*.mp3 >/dev/null 2>&1 && {
        list="$(mktemp)"
        for f in "$OUTDIR/${NAME}_part"*.mp3; do echo "file '$f'" >> "$list"; done
        ffmpeg -y -loglevel error -f concat -safe 0 -i "$list" -c copy "$OUTDIR/${NAME}_full.mp3" \
          && printf '%-44s %ss\n' "${NAME}_full.mp3" "$(duration_of "$OUTDIR/${NAME}_full.mp3")"
        rm -f "$list"
      }
    else
      echo "note: ffmpeg not found, parts not joined" >&2
    fi
    ;;
esac

echo "output: $OUTDIR"
[ "$DO_OPEN" -eq 1 ] && command -v open >/dev/null && open "$OUTDIR"
exit 0
