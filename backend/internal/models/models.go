package models

import "time"

// User represents a platform user.
type User struct {
	ID             uint      `gorm:"primaryKey" json:"id"`
	Email          string    `gorm:"uniqueIndex;size:255;not null" json:"email"`
	FullName       string    `gorm:"size:255;not null" json:"full_name"`
	HashedPassword string    `gorm:"size:255;not null" json:"-"`
	CreatedAt      time.Time `gorm:"autoCreateTime" json:"created_at"`
}

// InstrumentType categories.
type InstrumentType string

const (
	InstrumentEquity     InstrumentType = "equity"
	InstrumentMiniIndice InstrumentType = "mini_indice"
	InstrumentMiniDolar  InstrumentType = "mini_dolar"
)

// Recommendation enumerates trade signals.
type Recommendation string

const (
	RecommendationBuy  Recommendation = "buy"
	RecommendationSell Recommendation = "sell"
	RecommendationHold Recommendation = "hold"
)

// SignalSnapshot stores generated recommendations.
type SignalSnapshot struct {
	ID             uint            `gorm:"primaryKey" json:"id"`
	Symbol         string          `gorm:"index;size:50;not null" json:"symbol"`
	InstrumentType InstrumentType  `gorm:"index;size:20;not null" json:"instrument_type"`
	Timeframe      string          `gorm:"size:10;not null" json:"timeframe"`
	Recommendation Recommendation  `gorm:"size:10;not null" json:"recommendation"`
	Confidence     float64         `gorm:"not null" json:"confidence"`
	Summary        string          `gorm:"size:500;not null" json:"summary"`
	ParametersJSON string          `gorm:"type:text;not null" json:"parameters"`
	IndicatorsJSON string          `gorm:"type:text;not null" json:"indicators"`
	CreatedAt      time.Time       `gorm:"autoCreateTime" json:"created_at"`
}
