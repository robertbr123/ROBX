import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import axios from 'axios';
import yahooFinance from 'yahoo-finance2';

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

function normalizeSymbol(symbol) {
  if (!symbol) return 'AAPL';
  const s = String(symbol).trim().toUpperCase();
  // B3: PETR4 -> PETR4.SA
  if (/^[A-Z]{4}\d$/.test(s) && !s.endsWith('.SA')) return s + '.SA';
  return s;
}

app.get('/api/health', (req, res) => {
  res.json({ ok: true, ts: new Date().toISOString() });
});

app.get('/api/quote', async (req, res) => {
  try {
    const { symbol } = req.query;
    const sym = normalizeSymbol(symbol);
    const q = await yahooFinance.quote(sym);
    const price = q?.regularMarketPrice ?? q?.postMarketPrice ?? q?.preMarketPrice;
    const change = q?.regularMarketChangePercent ?? q?.postMarketChangePercent ?? q?.preMarketChangePercent ?? 0;
    if (!isFinite(price)) return res.status(404).json({ error: 'No price' });
    res.json({ symbol: sym, price, change });
  } catch (e) {
    console.error('quote error:', e.message);
    res.status(500).json({ error: 'quote_failed' });
  }
});

app.get('/api/series', async (req, res) => {
  try {
    const { symbol, interval = '1m', range = '1d' } = req.query;
    const sym = normalizeSymbol(symbol);
    const validIntervals = new Set(['1m','2m','5m','15m','30m','60m','90m','1h']);
    const i = validIntervals.has(interval) ? interval : '1m';
    const params = { interval: i, range };
    const chart = await yahooFinance.chart(sym, params);
    const result = chart?.result?.[0];
    if (!result) return res.status(404).json({ error: 'no_result' });
    const closes = result.indicators?.quote?.[0]?.close || [];
    const timestamps = result.timestamp || [];
    const items = [];
    for (let idx = 0; idx < Math.min(closes.length, timestamps.length); idx++){
      const y = closes[idx];
      if (y == null) continue;
      const t = timestamps[idx] * 1000;
      items.push({ t, y: Number(y) });
    }
    res.json({ symbol: sym, interval: i, range, items });
  } catch (e) {
    console.error('series error:', e.message);
    res.status(500).json({ error: 'series_failed' });
  }
});

app.get('/api/hg/quote', async (req, res) => {
  try {
    const { symbol } = req.query;
    const sym = String(symbol || 'PETR4').toUpperCase();
    const key = process.env.HG_KEY;
    if (!key) return res.status(400).json({ error: 'missing_hg_key' });
    const url = `https://api.hgbrasil.com/finance/stock_price?key=${encodeURIComponent(key)}&symbol=${encodeURIComponent(sym)}`;
    const r = await axios.get(url);
    const first = Object.values(r.data?.results || {})[0] || {};
    const price = Number(first?.price || first?.current_price || NaN);
    if (!isFinite(price)) return res.status(404).json({ error: 'No price' });
    res.json({ symbol: sym, price });
  } catch (e) {
    console.error('hg error:', e.message);
    res.status(500).json({ error: 'hg_failed' });
  }
});

app.listen(PORT, () => {
  console.log(`ROBX API running on http://localhost:${PORT}`);
});
