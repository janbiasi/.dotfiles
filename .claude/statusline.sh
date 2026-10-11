#!/usr/bin/env bash
# Claude Code status line:
#   Opus 5.5 | 󰪠 42% | $28.85 | in 880k out 4.9M total 20.8M | cache ● 1h ████░░ 38m left · hit 91% · misses 0
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

  # Nerd Font circle: outline under 6.25%, then circle_slice_1..8 in eighths
  def ring($p):
    ["󰝦", "󰪞", "󰪟", "󰪠", "󰪡", "󰪢", "󰪣", "󰪤", "󰪥"][if $p == null then 0 else ([($p / 12.5 | round), 8] | min) end]
    | paint(if $p != null and $p >= warn_at then "31" else "34" end);

  # Prompt cache (v2.1.251+), absent until the first API response. Status part coloured, stats plain;
  # green while warm, yellow under 20% of the TTL left, red when cold.
  def left: if . >= 3600 then "\(. / 3600 | floor)h \(. % 3600 / 60 | floor)m"
    elif . >= 60 then "\(. / 60 | ceil)m" else "\(. | ceil)s" end;
  def ttl_secs: {"5m": 300, "1h": 3600}[. // ""];
  def cbar($frac; $c): ($frac * 6 | ceil) as $f | ("█" * $f | paint($c)) + ("░" * (6 - $f) | dim);
  def cache:
    (if .expires_at != null then .expires_at - now else null end) as $rem
    | if .warm == true and ($rem == null or $rem > 0) then
        (.ttl | ttl_secs) as $ttl
        | (if $ttl != null and $rem != null then ([$rem / $ttl, 1] | min) else null end) as $frac
        | (if $frac != null and $frac < 0.2 then "33" else "32" end) as $c
        | [ ("cache ● " + (.ttl // "" | if . != "" then . + " " else . end) | paint($c))
              + (if $frac != null then cbar($frac; $c) + " " else "" end)
              + (if $rem != null then ($rem | left) + " left" | paint($c) else "" end),
            (.hit_ratio // empty | "hit \(. * 100 | round)%"),
            (.misses // empty | "misses \(.)") ]
      else
        [ ("cache ○ cold" | paint("31")),
          (.recache_tokens_if_cold // empty | "next message re-caches \(fmt) tokens"),
          (.last_miss_cause.causes? // [] | select(length > 0) | "last miss: " + join(", ")) ]
      end
    | join(" " + ("·" | dim) + " ");

  .context_window.used_percentage as $ctx
  | [
      (.model.display_name // .model.id | paint("35")),
      ring($ctx) + " " + (if $ctx == null then ("–" | dim) else ($ctx | pct) end),
      (.cost.total_cost_usd // empty | money | paint("32")),
      ([["in", $t.input], ["out", $t.output], ["total", $t.input + $t.output + $t.cache]]
        | map((.[0] | dim) + " " + (.[1] | fmt | bold)) | join(" ")),
      (.prompt_cache // empty | cache)
    ]
  | join(" " + ("|" | dim) + " ")
' <<<"$input"
