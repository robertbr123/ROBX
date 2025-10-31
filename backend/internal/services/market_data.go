package services

import (
	"errors"
	"time"

	"github.com/piquette/finance-go/chart"
)

// MarketCandle holds OHLCV data point.
type MarketCandle struct {
	Timestamp time.Time
	Open      float64
	High      float64
	Low       float64
	Close     float64
	Volume    float64
}

// MarketSeries includes metadata and candles.
type MarketSeries struct {
	Symbol    string
	Timeframe string
	Candles   []MarketCandle
}

// FetchMarketSeries returns market data using Yahoo Finance.
func FetchMarketSeries(symbol, timeframe string) (MarketSeries, error) {
	period, interval := timeframeToPeriodInterval(timeframe)
	if period == "" {
		return MarketSeries{}, errors.New("unsupported timeframe")
	}

	r := chart.Get(&chart.Params{
		Symbol:   symbol,
		Interval: interval,
		Range:    period,
	})

	candles := make([]MarketCandle, 0)
	for r.Next() {
		bar := r.Bar()
		if bar == nil {
			continue
		}
		candles = append(candles, MarketCandle{
			Timestamp: time.Unix(int64(bar.Timestamp), 0),
			Open:      bar.Open,
			High:      bar.High,
			Low:       bar.Low,
			Close:     bar.Close,
			Volume:    bar.Volume,
		})
	}

	if err := r.Err(); err != nil {
		return MarketSeries{}, err
	}

	if len(candles) == 0 {
		return MarketSeries{}, errors.New("no market data available")
	}

	return MarketSeries{Symbol: symbol, Timeframe: timeframe, Candles: candles}, nil
}

func timeframeToPeriodInterval(timeframe string) (string, string) {
	switch timeframe {
	case "1m":
		return "5d", "1m"
	case "5m":
		return "1mo", "5m"
	case "15m":
		return "2mo", "15m"
	case "1h":
		return "6mo", "1h"
	case "1d":
		return "1y", "1d"
	case "1wk":
		return "5y", "1wk"
	case "1mo":
		return "10y", "1mo"
	default:
		return "", ""
	}
}
