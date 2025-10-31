package config

import (
	"log"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/joho/godotenv"
)

// Settings holds application configuration.
type Settings struct {
	AppName                 string
	ServerPort              string
	SecretKey               string
	AccessTokenExpire       time.Duration
	DatabaseURL             string
	DefaultAssets           []string
	DefaultMiniIndice       string
	DefaultMiniDolar        string
	AdminEmail              string
	AdminPassword           string
	AdminFullName           string
	FrontendAllowedOrigins  []string
}

// Load reads environment variables from .env (when present) and populates Settings.
func Load() Settings {
	_ = godotenv.Load()

	settings := Settings{}
	settings.AppName = getenv("ROBX_APP_NAME", "ROBX Signals API")
	settings.ServerPort = getenv("ROBX_SERVER_PORT", "8000")
	settings.SecretKey = mustGetenv("ROBX_SECRET_KEY")
	settings.DatabaseURL = getenv("ROBX_DB_URL", "sqlite://./robx.db")
	settings.AccessTokenExpire = time.Duration(getenvInt("ROBX_ACCESS_TOKEN_EXPIRE_MINUTES", 120)) * time.Minute
	settings.DefaultAssets = parseList(getenv("ROBX_DEFAULT_ASSETS", "PETR4.SA,VALE3.SA,BBDC4.SA"))
	settings.DefaultMiniIndice = getenv("ROBX_DEFAULT_MINI_INDICE", "WIN=F")
	settings.DefaultMiniDolar = getenv("ROBX_DEFAULT_MINI_DOLAR", "WDO=F")
	settings.AdminEmail = getenv("ROBX_ADMIN_EMAIL", "")
	settings.AdminPassword = getenv("ROBX_ADMIN_PASSWORD", "")
	settings.AdminFullName = getenv("ROBX_ADMIN_FULL_NAME", "Administrador ROBX")
	settings.FrontendAllowedOrigins = parseList(getenv("ROBX_CORS_ORIGINS", "http://localhost:5173"))

	return settings
}

func getenv(key, fallback string) string {
	if value, ok := os.LookupEnv(key); ok {
		return value
	}
	return fallback
}

func mustGetenv(key string) string {
	value := os.Getenv(key)
	if value == "" {
		log.Fatalf("Environment variable %s is required", key)
	}
	return value
}

func getenvInt(key string, fallback int) int {
	if value, ok := os.LookupEnv(key); ok {
		parsed, err := strconv.Atoi(value)
		if err == nil {
			return parsed
		}
	}
	return fallback
}

func parseList(raw string) []string {
	parts := strings.Split(raw, ",")
	result := make([]string, 0, len(parts))
	for _, p := range parts {
		p = strings.TrimSpace(p)
		if p != "" {
			result = append(result, p)
		}
	}
	return result
}
