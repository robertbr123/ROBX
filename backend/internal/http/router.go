package http

import (
	"encoding/json"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"robx-backend/internal/config"
	"robx-backend/internal/dto"
	"robx-backend/internal/middleware"
	"robx-backend/internal/models"
	"robx-backend/internal/services"
)

// NewRouter configures and returns the HTTP router.
func NewRouter(db *gorm.DB, settings config.Settings) *gin.Engine {
	authService := services.AuthService{DB: db, Settings: settings}
	signalService := services.SignalEngine{}

	router := gin.Default()
	router.Use(cors.New(cors.Config{
		AllowOrigins:     settings.FrontendAllowedOrigins,
		AllowMethods:     []string{"GET", "POST"},
		AllowHeaders:     []string{"Authorization", "Content-Type"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	}))

	router.GET("/", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"message": "ROBX Signals API operacional"})
	})

	authGroup := router.Group("/auth")
	{
		authGroup.POST("/register", func(c *gin.Context) {
			var body dto.RegisterRequest
			if err := c.ShouldBindJSON(&body); err != nil {
				c.JSON(http.StatusBadRequest, gin.H{"detail": err.Error()})
				return
			}

			if _, err := authService.GetUserByEmail(body.Email); err == nil {
				c.JSON(http.StatusConflict, gin.H{"detail": "Email em uso"})
				return
			}

			user, err := authService.CreateUser(body.Email, body.FullName, body.Password)
			if err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"detail": err.Error()})
				return
			}

			c.JSON(http.StatusCreated, dto.NewUserResponse(*user))
		})

		authGroup.POST("/login", func(c *gin.Context) {
			var body dto.LoginRequest
			if err := c.ShouldBindJSON(&body); err != nil {
				c.JSON(http.StatusBadRequest, gin.H{"detail": err.Error()})
				return
			}

			user, err := authService.GetUserByEmail(body.Email)
			if err != nil || !authService.VerifyPassword(user.HashedPassword, body.Password) {
				c.JSON(http.StatusUnauthorized, gin.H{"detail": "Credenciais inválidas"})
				return
			}

			token, err := authService.CreateAccessToken(user.Email)
			if err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"detail": err.Error()})
				return
			}

			c.JSON(http.StatusOK, dto.TokenResponse{AccessToken: token, TokenType: "bearer"})
		})
	}

	signalsGroup := router.Group("/signals")
	signalsGroup.Use(middleware.AuthMiddleware(authService))
	{
		signalsGroup.POST("", func(c *gin.Context) {
			var body dto.SignalRequest
			if err := c.ShouldBindJSON(&body); err != nil {
				c.JSON(http.StatusBadRequest, gin.H{"detail": err.Error()})
				return
			}

			params := dto.SignalParameters{}
			if body.Parameters != nil {
				params = body.Parameters.WithDefaults()
			} else {
				params = params.WithDefaults()
			}

			symbol := resolveSymbol(settings, body)

			series, err := services.FetchMarketSeries(symbol, body.Timeframe)
			if err != nil {
				c.JSON(http.StatusBadRequest, gin.H{"detail": err.Error()})
				return
			}

			rec, confidence, summary, indicators := signalService.Evaluate(series, params)

			serializedParams, _ := json.Marshal(params)
			serializedIndicators, _ := json.Marshal(indicators)

			snapshot := models.SignalSnapshot{
				Symbol:         symbol,
				InstrumentType: body.InstrumentType,
				Timeframe:      body.Timeframe,
				Recommendation: rec,
				Confidence:     confidence,
				Summary:        summary,
				ParametersJSON: string(serializedParams),
				IndicatorsJSON: string(serializedIndicators),
			}
			if err := db.Create(&snapshot).Error; err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"detail": err.Error()})
				return
			}

			c.JSON(http.StatusOK, dto.SignalResponse{
				Recommendation: rec,
				Confidence:     confidence,
				Summary:        summary,
				Symbol:         symbol,
				InstrumentType: body.InstrumentType,
				Timeframe:      body.Timeframe,
				Parameters:     params,
				Indicators:     indicators,
				CreatedAt:      snapshot.CreatedAt,
			})
		})

		signalsGroup.GET("/history", func(c *gin.Context) {
			instrument := c.Query("instrument")
			limit := 20
			if queryLimit := c.Query("limit"); queryLimit != "" {
				if parsed, err := strconv.Atoi(queryLimit); err == nil && parsed > 0 && parsed <= 100 {
					limit = parsed
				}
			}

			var snapshots []models.SignalSnapshot
			query := db.Order("created_at DESC").Limit(limit)
			if instrument != "" {
				query = query.Where("instrument_type = ?", instrument)
			}
			if err := query.Find(&snapshots).Error; err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"detail": err.Error()})
				return
			}

			items := make([]dto.SignalResponse, 0, len(snapshots))
			for _, snapshot := range snapshots {
				var params dto.SignalParameters
				_ = json.Unmarshal([]byte(snapshot.ParametersJSON), &params)
				var indicators map[string]float64
				_ = json.Unmarshal([]byte(snapshot.IndicatorsJSON), &indicators)
				items = append(items, dto.SignalResponse{
					Recommendation: snapshot.Recommendation,
					Confidence:     snapshot.Confidence,
					Summary:        snapshot.Summary,
					Symbol:         snapshot.Symbol,
					InstrumentType: snapshot.InstrumentType,
					Timeframe:      snapshot.Timeframe,
					Parameters:     params.WithDefaults(),
					Indicators:     indicators,
					CreatedAt:      snapshot.CreatedAt,
				})
			}

			c.JSON(http.StatusOK, dto.SignalHistoryResponse{Items: items})
		})
	}

	return router
}

func resolveSymbol(settings config.Settings, request dto.SignalRequest) string {
	if request.Symbol != "" {
		return request.Symbol
	}
	switch request.InstrumentType {
	case models.InstrumentMiniIndice:
		return settings.DefaultMiniIndice
	case models.InstrumentMiniDolar:
		return settings.DefaultMiniDolar
	default:
		if len(settings.DefaultAssets) > 0 {
			return settings.DefaultAssets[0]
		}
		return "PETR4.SA"
	}
}
