package services

import (
	"fmt"
	"math"

	"robx-backend/internal/dto"
	"robx-backend/internal/models"
)

// SignalEngine calculates trading signals.
type SignalEngine struct{}

// Evaluate generates signal recommendation.
func (SignalEngine) Evaluate(series MarketSeries, params dto.SignalParameters) (models.Recommendation, float64, string, map[string]float64) {
	params = params.WithDefaults()
	candles := series.Candles
	length := len(candles)
	if length == 0 {
		return models.RecommendationHold, 0, "Sem dados suficientes", map[string]float64{}
	}

	closes := make([]float64, length)
	volumes := make([]float64, length)
	for i, c := range candles {
		closes[i] = c.Close
		volumes[i] = c.Volume
	}

	smaShort := simpleMovingAverage(closes, params.ShortWindow)
	smaLong := simpleMovingAverage(closes, params.LongWindow)
	rsi := computeRSI(closes, params.RSIPeriod)
	volumeMA := simpleMovingAverage(volumes, params.VolumeWindow)
	volatility := rollingVolatility(closes, params.VolatilityWindow)

	lastIndex := length - 1
	latestClose := closes[lastIndex]
	latestRSI := rsi[lastIndex]
	latestShort := smaShort[lastIndex]
	latestLong := smaLong[lastIndex]
	latestVolume := volumes[lastIndex]
	latestVolumeMA := volumeMA[lastIndex]
	latestVolatility := volatility[lastIndex]

	score := 50.0
	if latestShort > latestLong && latestClose > latestShort {
		score += 20
	} else if latestShort < latestLong && latestClose < latestShort {
		score -= 20
	}

	if latestRSI <= float64(params.RSIOversold) {
		score += 15
	} else if latestRSI >= float64(params.RSIOverbought) {
		score -= 15
	}

	volumeRatio := 1.0
	if latestVolumeMA > 0 {
		volumeRatio = latestVolume / latestVolumeMA
	}

	if volumeRatio > 1.2 {
		score += 5
	} else if volumeRatio < 0.8 {
		score -= 5
	}

	if latestVolatility > 0 {
		if latestVolatility < 0.02 {
			score += 5
		} else if latestVolatility > 0.06 {
			score -= 5
		}
	}

	score = math.Max(0, math.Min(100, score))
	recommendation := models.RecommendationHold
	if score >= 60 {
		recommendation = models.RecommendationBuy
	} else if score <= 40 {
		recommendation = models.RecommendationSell
	}

	confidence := math.Round(score) / 100
	summary := buildSummary(recommendation, latestRSI, params.ShortWindow, params.LongWindow)

	indicators := map[string]float64{
		"close":       round(latestClose, 4),
		"sma_short":   round(latestShort, 4),
		"sma_long":    round(latestLong, 4),
		"rsi":         round(latestRSI, 2),
		"volume":      round(latestVolume, 2),
		"volume_ma":   round(latestVolumeMA, 2),
		"volume_ratio": round(volumeRatio, 2),
		"volatility":  round(latestVolatility, 4),
	}

	return recommendation, confidence, summary, indicators
}

func simpleMovingAverage(values []float64, window int) []float64 {
	result := make([]float64, len(values))
	if window <= 1 {
		copy(result, values)
		return result
	}
	var sum float64
	for i := range values {
		sum += values[i]
		if i >= window {
			sum -= values[i-window]
		}
		if i >= window-1 {
			result[i] = sum / float64(window)
		} else {
			result[i] = values[i]
		}
	}
	return result
}

func computeRSI(closes []float64, period int) []float64 {
	if period < 2 {
		period = 14
	}
	rsi := make([]float64, len(closes))
	var gainSum, lossSum float64
	for i := 1; i < len(closes); i++ {
		change := closes[i] - closes[i-1]
		gain := math.Max(change, 0)
		loss := math.Max(-change, 0)
		if i <= period {
			gainSum += gain
			lossSum += loss
			rsi[i] = 50
			continue
		}
		avgGain := (gainSum*(float64(period)-1) + gain) / float64(period)
		avgLoss := (lossSum*(float64(period)-1) + loss) / float64(period)
		gainSum = avgGain * float64(period)
		lossSum = avgLoss * float64(period)
		if avgLoss == 0 {
			rsi[i] = 100
			continue
		}
		rs := avgGain / avgLoss
		rsi[i] = 100 - (100 / (1 + rs))
	}
	if len(closes) > 0 {
		rsi[0] = 50
	}
	return rsi
}

func rollingVolatility(values []float64, window int) []float64 {
	if window < 2 {
		window = 20
	}
	result := make([]float64, len(values))
	returns := make([]float64, len(values))
	for i := 1; i < len(values); i++ {
		if values[i-1] != 0 {
			returns[i] = (values[i] - values[i-1]) / values[i-1]
		}
	}
	for i := range returns {
		if i < window {
			result[i] = 0
			continue
		}
		var sum float64
		for j := i - window + 1; j <= i; j++ {
			sum += returns[j]
		}
		mean := sum / float64(window)
		var variance float64
		for j := i - window + 1; j <= i; j++ {
			diff := returns[j] - mean
			variance += diff * diff
		}
		result[i] = math.Sqrt(variance / float64(window))
	}
	return result
}

func buildSummary(rec models.Recommendation, rsi float64, short, long int) string {
	switch rec {
	case models.RecommendationBuy:
		return fmtSummary("Força compradora dominando", rsi, short, long)
	case models.RecommendationSell:
		return fmtSummary("Pressão vendedora dominante", rsi, short, long)
	default:
		return fmtSummary("Cenário neutro, aguarde confirmação", rsi, short, long)
	}
}


func fmtSummary(phrase string, rsi float64, short, long int) string {
	return fmt.Sprintf("%s; RSI em %.1f; Médias %d/%d alinhadas", phrase, rsi, short, long)
}

func round(value float64, precision int) float64 {
	factor := math.Pow(10, float64(precision))
	return math.Round(value*factor) / factor
}
