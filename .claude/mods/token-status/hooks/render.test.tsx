import { expect, test } from 'claude-code/testing'

const HINT = { isDraft: false, isWorking: false, hint: '? for shortcuts' }

test('draws the line in the prompt hint on the terminal', async ($, on) => {
  // The engine beneath the mod, stubbed.
  on('ui.render', { component: 'PromptHint' }, () => ({ type: 'Text', props: {}, children: ['ENGINE DEFAULT'] }))
  on('session.model', () => ({ value: 'claude-opus-5-5' }))
  on('session.usage', () => ({
    value: {
      startedAt: 0,
      context: { tokens: 84_000, window: 200_000, percent: 42 },
      rateLimits: [{ kind: 'five_hour', percentUsed: 23 }],
      cost: { usd: 1.5 },
    },
  }))
  on('session.measure', (_$, e) => ({ changed: e.changed }))

  await $.session.measure({ context: { window: 200_000, percent: 42 }, rateLimits: [], changed: ['context'] })

  const ui = await $.ui.mount({ plugin: 'token-status', surface: 'terminal', component: 'PromptHint', props: HINT })
  const drawn = JSON.stringify(await ui.drawn())
  expect(drawn.includes('ENGINE DEFAULT')).toBe(false)
  expect(drawn.includes('Opus 5.5')).toBe(true)
  expect(drawn.includes('"magenta"')).toBe(true)
  expect(drawn.includes('42%')).toBe(true)
  expect(drawn.includes('dotfiles') || drawn.includes(' · ') || drawn.includes(' of ')).toBe(false)
})
