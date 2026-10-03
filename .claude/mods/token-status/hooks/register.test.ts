import { expect, test } from 'claude-code/testing'

import { bar, COLOR, fmt, groups, modelName, money, plain } from './register'

const t = { input: 880_000, output: 4_900_000, cache: 15_000_000 }
const base = { model: 'claude-opus-5-5', limits: [] }

const find = (gs: ReturnType<typeof groups>, text: string) => gs.flat().find(s => s.text === text)

test('formats numbers like cc-statusline', () => {
  expect(fmt(950)).toBe('950')
  expect(fmt(880_000)).toBe('880k')
  expect(fmt(4_900_000)).toBe('4.9M')
  expect(fmt(1_100_000_000)).toBe('1.1B')
  expect(money(28.852)).toBe('$28.85')
  expect(money(811.4)).toBe('$811')
})

test('names models', () => {
  expect(modelName('claude-opus-5-5')).toBe('Opus 5.5')
  expect(modelName('claude-haiku-4-5-20251001')).toBe('Haiku 4.5')
})

test('draws the whole bar in one colour', () => {
  expect(bar(42)).toEqual({ text: '████░░░░░░', color: 'bar' })
  expect(bar(100)).toEqual({ text: '██████████', color: 'alert' })
  expect(bar(undefined)).toEqual({ text: '░░░░░░░░░░', color: 'bar' })
})

test('lays out one row without dots, repo or context limit', () => {
  const s = { ...base, percent: 42, usd: 28.85, limits: [{ name: '5h', percent: 23 }, { name: '7d', percent: 41 }] }
  expect(plain(groups(s, t))).toBe(
    'Opus 5.5 | ████░░░░░░ 42% | $28.85 | in 880k out 4.9M cache 15.0M total 20.8M | 5h 23% 7d 41%',
  )
})

test('model is magenta; labels dim, values bold and uncoloured', () => {
  const gs = groups({ ...base, percent: 42, limits: [{ name: '5h', percent: 23 }] }, t)
  expect(COLOR[find(gs, 'Opus 5.5')?.color ?? 'bar']).toBe('magenta')
  for (const label of ['in ', ' out ', ' cache ', ' total ', '5h ']) {
    expect(find(gs, label)).toEqual({ text: label, dim: true })
  }
  expect(find(gs, '880k')).toEqual({ text: '880k', bold: true })
  expect(find(gs, ' 42%')).toEqual({ text: ' 42%', bold: true })
})

test('turns alert at 80%', () => {
  expect(find(groups({ ...base, percent: 79 }, t), ' 79%')?.color).toBe(undefined)
  const full = groups({ ...base, percent: 85, limits: [{ name: '5h', percent: 90 }] }, t)
  expect(find(full, ' 85%')?.color).toBe('alert')
  expect(find(full, '90%')?.color).toBe('alert')
  expect(find(full, '████████░░')?.color).toBe('alert')
})

test('every colour is a terminal ANSI colour name', () => {
  for (const c of Object.values(COLOR)) {
    expect(/^(black|red|green|yellow|blue|magenta|cyan|white|gray)(Bright)?$/.test(c)).toBe(true)
  }
})

test('drops absent parts before the first response', () => {
  expect(plain(groups(base, { input: 0, output: 0, cache: 0 }))).toBe(
    'Opus 5.5 | ░░░░░░░░░░ – | in 0 out 0 cache 0 total 0',
  )
})
