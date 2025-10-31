export type InstrumentType = "equity" | "mini_indice" | "mini_dolar";
export type Recommendation = "buy" | "sell" | "hold";

export interface SignalParameters {
  short_window: number;
  long_window: number;
  rsi_period: number;
  rsi_overbought: number;
  rsi_oversold: number;
  volume_window: number;
  volatility_window: number;
}

export interface SignalResponse {
  recommendation: Recommendation;
  confidence: number;
  summary: string;
  symbol: string;
  instrument_type: InstrumentType;
  timeframe: string;
  parameters: SignalParameters;
  created_at: string;
  indicators: Record<string, number>;
}

export interface SignalHistoryResponse {
  items: SignalResponse[];
}

export interface TokenResponse {
  access_token: string;
  token_type: string;
}

export interface SignalRequest {
  instrument_type: InstrumentType;
  symbol?: string;
  timeframe: "1m" | "5m" | "15m" | "1h" | "1d" | "1wk" | "1mo";
  parameters?: Partial<SignalParameters>;
}
