// in: uncached input; cache: cache reads + writes; output: generated.
export type Totals = { input: number; output: number; cache: number }

export type RateLimit = { name: string; percent: number }

// What the prompt line draws, refreshed after each turn and measurement.
export type Snapshot = {
  model: string
  percent?: number
  usd?: number
  limits: RateLimit[]
}

declare module 'claude-code' {
  interface PluginState {
    'token-status': { totals: Totals; hasWarned: boolean; snapshot: Snapshot | null }
  }
}
