import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register } from 'claude-code'

import type { Snapshot, Totals } from '../types'

// Styling after jantimon/cc-statusline. Terminal ANSI colour names only: no Claude Code theme key
// is named like them, so they pass through as the terminal's palette slots. (The engine refuses
// `ansi:` prefixes in a mod's tree and falls back to its own line.)
// Labels and separators are dim, values bold in the terminal foreground (no colour).
export const COLOR = {
  model: 'magenta',
  bar: 'blue',
  cost: 'green',
  alert: 'red', // anything at or past WARN_AT
} as const

export type Role = keyof typeof COLOR

// Fill (percent) at which a figure turns alert and the context toasts once.
export const WARN_AT = 80

const ZERO: Totals = { input: 0, output: 0, cache: 0 }
const totals = atom({ plugin: 'token-status', key: 'totals' } as const, ZERO)
const hasWarned = atom({ plugin: 'token-status', key: 'hasWarned' } as const, false)
const snapshot = atom({ plugin: 'token-status', key: 'snapshot' } as const, null as Snapshot | null)

// 950 -> 950, 12345 -> 12k, 4_900_000 -> 4.9M, 1.1e9 -> 1.1B
export const fmt = (n: number) =>
  n >= 1e9
    ? `${(n / 1e9).toFixed(1)}B`
    : n >= 1e6
      ? `${(n / 1e6).toFixed(1)}M`
      : n >= 1e3
        ? `${Math.round(n / 1e3)}k`
        : `${n}`

// $1.23 under $100, $811 above
export const money = (usd: number) => (usd >= 100 ? `$${Math.round(usd)}` : `$${usd.toFixed(2)}`)

// claude-opus-5-5 -> Opus 5.5, claude-haiku-4-5-20251001 -> Haiku 4.5
export const modelName = (id: string) => {
  const [family = id, ...version] = id
    .replace(/^claude-/, '')
    .replace(/-\d{8}$/, '')
    .split('-')
  return [family.charAt(0).toUpperCase() + family.slice(1), version.join('.')].filter(Boolean).join(' ')
}

const LIMIT_NAMES: Record<string, string> = { five_hour: '5h', seven_day: '7d', spend_limit: 'spend' }

// A run of text: coloured (`color`), dim (labels, separators) or bold (values); none of them is plain text.
export type Segment = { text: string; color?: Role; dim?: true; bold?: true }

const col = (color: Role, text: string): Segment => ({ text, color })
const dim = (text: string): Segment => ({ text, dim: true })
const val = (text: string, color?: Role): Segment => (color ? { text, color, bold: true } : { text, bold: true })

const isAlert = (percent: number) => percent >= WARN_AT

export const BAR_WIDTH = 10

// ████████░░: the whole bar in one colour, as cc-statusline draws it; alert past WARN_AT.
export const bar = (percent: number | undefined): Segment => {
  const filled = percent === undefined ? 0 : Math.min(BAR_WIDTH, Math.floor((percent / 100) * BAR_WIDTH))
  return col(percent !== undefined && isAlert(percent) ? 'alert' : 'bar', '█'.repeat(filled) + '░'.repeat(BAR_WIDTH - filled))
}

const pct = (percent: number) => val(`${percent}%`, isAlert(percent) ? 'alert' : undefined)

// `label value` pairs, space-separated: the dim label is the divider
const pairs = (items: [string, Segment][]): Segment[] =>
  items.flatMap(([label, value], i) => [dim(`${i > 0 ? ' ' : ''}${label} `), value])

// One row of groups; render puts a dim ' | ' between them.
export const groups = (s: Snapshot, t: Totals): Segment[][] =>
  [
    [col('model', modelName(s.model))],
    [bar(s.percent), s.percent === undefined ? dim(' –') : { ...pct(s.percent), text: ` ${s.percent}%` }],
    s.usd === undefined ? [] : [col('cost', money(s.usd))],
    pairs([
      ['in', val(fmt(t.input))],
      ['out', val(fmt(t.output))],
      ['cache', val(fmt(t.cache))],
      ['total', val(fmt(t.input + t.output + t.cache))],
    ]),
    pairs(s.limits.map(l => [l.name, pct(l.percent)])),
  ].filter(g => g.length > 0)

export const plain = (gs: Segment[][]) => gs.map(g => g.map(s => s.text).join('')).join(' | ')

const refresh = async ($: EngineInterface) => {
  const [model, usage] = await Promise.all([$.session.model(), $.session.usage()])
  const { percent } = usage.context
  await update($, snapshot, () => ({
    model,
    percent,
    usd: usage.cost?.usd,
    limits: usage.rateLimits.map(l => ({
      name: LIMIT_NAMES[l.kind] ?? l.kind,
      percent: Math.round(l.percentUsed),
    })),
  }))
  await warn($, percent)
}

// Toast once per crossing; re-arms when the fill drops back (e.g. after /compact).
const warn = async ($: EngineInterface, percent: number | undefined) => {
  const isOver = percent !== undefined && isAlert(percent)
  if (isOver === (await read($, hasWarned))) return
  await update($, hasWarned, () => isOver)
  if (isOver) $.ui.toast(`Context ${percent}% full — consider /compact`, { timeoutMs: 8000 })
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    const r = await next(e)
    $.ui.status(undefined) // clear the pinned notice an earlier version left
    await refresh($)
    return r
  })

  // Sums every turn, subagents included.
  on('turn.complete', async ($, e, next) => {
    const u = e.usage
    if (u) {
      await update($, totals, t => ({
        input: t.input + u.input_tokens,
        output: t.output + u.output_tokens,
        cache: (t.cache ?? 0) + u.cache_creation_input_tokens + u.cache_read_input_tokens,
      }))
    }
    await refresh($)
    return next(e)
  })

  // Context fill, cost and rate limits move after each turn and on /compact, /model etc.
  on('session.measure', async ($, e, next) => {
    await refresh($)
    return next(e)
  })

  // Replaces the hint under the prompt (shortcut guides, esc to interrupt) with one row.
  on('ui.render', { component: 'PromptHint' }, async ($, e, next) => {
    const s = await read($, snapshot)
    if (s === null) return next(e)

    const { Text } = $.ui.resolve(e)
    const t = await read($, totals)

    // One Text so groups never shrink individually; only the tail is cut when narrow.
    return (
      <Text wrap="truncate-end">
        {groups(s, { ...ZERO, ...t }).flatMap((g, i) => [
          ...(i > 0 ? [<Text key={`sep${i}`} dimColor> | </Text>] : []),
          ...g.map((sg, j) => (
            <Text
              key={`s${i}-${j}`}
              color={sg.color && COLOR[sg.color]}
              dimColor={sg.dim}
              bold={sg.bold}
            >
              {sg.text}
            </Text>
          )),
        ])}
      </Text>
    )
  })
}
