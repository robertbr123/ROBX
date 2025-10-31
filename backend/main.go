package main

import (
	"log"

	"gorm.io/gorm"

	"robx-backend/internal/config"
	"robx-backend/internal/database"
	"robx-backend/internal/handlers/seeder"
	"robx-backend/internal/http"
	"robx-backend/internal/models"
	"robx-backend/internal/services"
)

func main() {
	settings := config.Load()
	db := database.Connect(settings.DatabaseURL)
	autoMigrate(db)
	seedAdmin(db, settings)

	router := http.NewRouter(db, settings)
	if err := router.Run(":8000"); err != nil {
		log.Fatalf("cannot start server: %v", err)
	}
}

func autoMigrate(db *gorm.DB) {
	database.Migrate(db, &models.User{}, &models.SignalSnapshot{})
}

func seedAdmin(db *gorm.DB, settings config.Settings) {
	if settings.AdminEmail == "" || settings.AdminPassword == "" {
		return
	}
	authService := services.AuthService{DB: db, Settings: settings}
	if _, err := authService.GetUserByEmail(settings.AdminEmail); err == nil {
		return
	}
	if _, err := authService.CreateUser(settings.AdminEmail, settings.AdminFullName, settings.AdminPassword); err != nil {
		log.Printf("failed to create admin user: %v", err)
	}
}
