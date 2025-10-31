package dto

import (
	"time"

	"robx-backend/internal/models"
)

// TokenResponse contains JWT token info.
type TokenResponse struct {
	AccessToken string `json:"access_token"`
	TokenType   string `json:"token_type"`
}

// LoginRequest holds login credentials.
type LoginRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required"`
}

// RegisterRequest contains registration data.
type RegisterRequest struct {
	Email    string `json:"email" binding:"required,email"`
	FullName string `json:"full_name" binding:"required"`
	Password string `json:"password" binding:"required,min=8"`
}

// SignalParameters configures signal generation.
type SignalParameters struct {
	ShortWindow      int `json:"short_window"`
	LongWindow       int `json:"long_window"`
	RSIPeriod        int `json:"rsi_period"`
	RSIOverbought    int `json:"rsi_overbought"`
	RSIOversold      int `json:"rsi_oversold"`
	VolumeWindow     int `json:"volume_window"`
	VolatilityWindow int `json:"volatility_window"`
}

func (p SignalParameters) WithDefaults() SignalParameters {
	params := p
	if params.ShortWindow == 0 {
		params.ShortWindow = 14
	}
	if params.LongWindow == 0 {
		params.LongWindow = 50
	}
	if params.RSIPeriod == 0 {
		params.RSIPeriod = 14
	}
	if params.RSIOverbought == 0 {
		params.RSIOverbought = 70
	}
	if params.RSIOversold == 0 {
		params.RSIOversold = 30
	}
	if params.VolumeWindow == 0 {
		params.VolumeWindow = 20
	}
	if params.VolatilityWindow == 0 {
		params.VolatilityWindow = 20
	}
	return params
}

// SignalRequest triggers signal generation.
type SignalRequest struct {
	InstrumentType models.InstrumentType `json:"instrument_type" binding:"required"`
	Symbol         string                `json:"symbol"`
	Timeframe      string                `json:"timeframe" binding:"required,oneof=1m 5m 15m 1h 1d 1wk 1mo"`
	Parameters     *SignalParameters     `json:"parameters"`
}

// SignalResponse returns generated signal data.
type SignalResponse struct {
	Recommendation models.Recommendation `json:"recommendation"`
	Confidence     float64               `json:"confidence"`
	Summary        string                `json:"summary"`
	Symbol         string                `json:"symbol"`
	InstrumentType models.InstrumentType `json:"instrument_type"`
	Timeframe      string                `json:"timeframe"`
	Parameters     SignalParameters      `json:"parameters"`
	Indicators     map[string]float64    `json:"indicators"`
	CreatedAt      time.Time             `json:"created_at"`
}

// SignalHistoryResponse wraps historical signals.
type SignalHistoryResponse struct {
	Items []SignalResponse `json:"items"`
}

// UserResponse exposes user-safe fields.
type UserResponse struct {
	ID        uint      `json:"id"`
	Email     string    `json:"email"`
	FullName  string    `json:"full_name"`
	CreatedAt time.Time `json:"created_at"`
}

func NewUserResponse(u models.User) UserResponse {
	return UserResponse{
		ID:        u.ID,
		Email:     u.Email,
		FullName:  u.FullName,
		CreatedAt: u.CreatedAt,
	}
}
