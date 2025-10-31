package services

import (
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"net/url"
	"time"
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

var yahooHTTPClient = &http.Client{Timeout: 15 * time.Second}

type yahooChartResponse struct {
	Chart struct {
		Result []struct {
			Meta struct {
				Symbol string `json:"symbol"`
			} `json:"meta"`
			Timestamp []int64 `json:"timestamp"`
			Indicators struct {
				Quote []struct {
					Open   []*float64 `json:"open"`
					High   []*float64 `json:"high"`
					Low    []*float64 `json:"low"`
					Close  []*float64 `json:"close"`
					Volume []*float64 `json:"volume"`
				} `json:"quote"`
			} `json:"indicators"`
		} `json:"result"`
		Error *struct {
			Code        string `json:"code"`
			Description string `json:"description"`
		} `json:"error"`
	} `json:"chart"`
}

// FetchMarketSeries returns market data using Yahoo Finance.
func FetchMarketSeries(symbol, timeframe string) (MarketSeries, error) {
	period, interval := timeframeToPeriodInterval(timeframe)
	if period == "" {
		return MarketSeries{}, errors.New("unsupported timeframe")
	}

	queryURL := fmt.Sprintf(
		"https://query1.finance.yahoo.com/v8/finance/chart/%s?range=%s&interval=%s",
		url.QueryEscape(symbol),
		url.QueryEscape(period),
		url.QueryEscape(interval),
	)

	req, err := http.NewRequest(http.MethodGet, queryURL, nil)
	if err != nil {
		return MarketSeries{}, err
	}
	req.Header.Set("Accept", "application/json")

	resp, err := yahooHTTPClient.Do(req)
	if err != nil {
		return MarketSeries{}, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return MarketSeries{}, fmt.Errorf("yahoo finance request failed: status %d", resp.StatusCode)
	}

	var payload yahooChartResponse
	if err := json.NewDecoder(resp.Body).Decode(&payload); err != nil {
		return MarketSeries{}, err
	}

	if payload.Chart.Error != nil {
		return MarketSeries{}, fmt.Errorf("yahoo finance error: %s", payload.Chart.Error.Description)
	}

	if len(payload.Chart.Result) == 0 {
		return MarketSeries{}, errors.New("no market data available")
	}

	series := payload.Chart.Result[0]
	if len(series.Indicators.Quote) == 0 {
		return MarketSeries{}, errors.New("no quote data available")
	}

	quote := series.Indicators.Quote[0]
	length := len(series.Timestamp)
	candles := make([]MarketCandle, 0, length)
	for i := 0; i < length; i++ {
		ts := series.Timestamp[i]
		if ts == 0 || i >= len(quote.Close) {
			continue
		}
		open := valueAt(quote.Open, i)
		high := valueAt(quote.High, i)
		low := valueAt(quote.Low, i)
		close := valueAt(quote.Close, i)
		volume := valueAt(quote.Volume, i)

		// Yahoo can return null entries; skip incomplete rows.
		if open == nil || high == nil || low == nil || close == nil {
			continue
		}

		candles = append(candles, MarketCandle{
			Timestamp: time.Unix(ts, 0),
			Open:      *open,
			High:      *high,
			Low:       *low,
			Close:     *close,
			Volume:    valueOrZero(volume),
		})
	}

	if len(candles) == 0 {
		return MarketSeries{}, errors.New("no market data available")
	}

	resolvedSymbol := series.Meta.Symbol
	if resolvedSymbol == "" {
		resolvedSymbol = symbol
	}

	return MarketSeries{Symbol: resolvedSymbol, Timeframe: timeframe, Candles: candles}, nil
}

func valueAt(items []*float64, idx int) *float64 {
	if idx >= len(items) {
		return nil
	}
	return items[idx]
}

func valueOrZero(val *float64) float64 {
	if val == nil {
		return 0
	}
	return *val
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
