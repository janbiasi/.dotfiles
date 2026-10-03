#!/usr/bin/env bash
# Claude Code status line:
#   Opus 5.5 | ████░░░░░░ 42% | $28.85 | in 880k out 4.9M cache 15.0M total 20.8M | 5h 23% 7d 41%
# Reads the status-line JSON on stdin. Terminal ANSI colours only, so it follows the terminal theme.
set -uo pipefail
shopt -s nullglob

input=$(cat)

# Session token totals are not in the payload: sum every assistant response in the transcript
# and its subagents' transcripts. Streaming writes a record several times with a growing
# output count, so dedupe by (message.id, requestId) keeping the largest.
totals='{"input":0,"output":0,"cache":0}'
transcript=$(jq -r '.transcript_path // empty' <<<"$input")
if [[ -n $transcript && -f $transcript ]]; then
  files=("$transcript" "${transcript%.jsonl}"/subagents/*.jsonl)
  totals=$(jq -cnR '
    [inputs | fromjson? | select(.type == "assistant" and .message.usage != null)
      | {k: "\(.message.id)/\(.requestId)", u: .message.usage}]
    | group_by(.k) | map(max_by(.u.output_tokens // 0).u)
    | {input: (map(.input_tokens // 0) | add // 0),
       output: (map(.output_tokens // 0) | add // 0),
       cache: (map((.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)) | add // 0)}
  ' "${files[@]}" 2>/dev/null) || totals='{"input":0,"output":0,"cache":0}'
fi

jq -rj --argjson t "$totals" '
  def sgr(c): "\u001b[\(c)m";
  def paint(c): sgr(c) + . + sgr("0");
  def dim: paint("2");
  def bold: paint("1");
  def warn_at: 80;

  # 950 -> 950, 12345 -> 12k, 4.9e6 -> 4.9M, 1.1e9 -> 1.1B
  def one: (. * 10 | round) as $n | "\($n / 10 | floor).\($n % 10)";
  def fmt:
    if . >= 1e9 then "\(. / 1e9 | one)B"
    elif . >= 1e6 then "\(. / 1e6 | one)M"
    elif . >= 1e3 then "\(. / 1e3 | round)k"
    else "\(. | round)" end;
  # $28.85 under $100, $811 above
  def money:
    if . >= 100 then "$\(. | round)"
    else (. * 100 | round) as $c | "$\($c / 100 | floor).\($c % 100 | tostring | if length < 2 then "0" + . else . end)" end;
  def pct: (. | round) as $p | "\($p)%" | if $p >= warn_at then paint("1;31") else bold end;

  def bar($p):
    (if $p == null then 0 else ([($p / 10 | floor), 10] | min) end) as $f
    | ("█" * $f) + ("░" * (10 - $f))
    | paint(if $p != null and $p >= warn_at then "31" else "34" end);

  .context_window.used_percentage as $ctx
  | [
      (.model.display_name // .model.id | paint("35")),
      bar($ctx) + " " + (if $ctx == null then ("–" | dim) else ($ctx | pct) end),
      (.cost.total_cost_usd // empty | money | paint("32")),
      ([["in", $t.input], ["out", $t.output], ["cache", $t.cache], ["total", $t.input + $t.output + $t.cache]]
        | map((.[0] | dim) + " " + (.[1] | fmt | bold)) | join(" ")),
      ([["5h", .rate_limits.five_hour], ["7d", .rate_limits.seven_day], ["spend", .rate_limits.spend_limit]]
        | map(select(.[1] != null) | (.[0] | dim) + " " + (.[1].used_percentage | pct))
        | select(length > 0) | join(" "))
    ]
  | join(" " + ("|" | dim) + " ")
' <<<"$input"
