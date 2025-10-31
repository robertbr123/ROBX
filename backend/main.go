package main

import (
	"errors"
	"log"

	"gorm.io/gorm"

	"robx-backend/internal/config"
	"robx-backend/internal/database"
	httprouter "robx-backend/internal/http"
	"robx-backend/internal/models"
	"robx-backend/internal/services"
)

func main() {
	settings := config.Load()
	db := database.Connect(settings.DatabaseURL)
	autoMigrate(db)
	seedAdmin(db, settings)

	router := httprouter.NewRouter(db, settings)
	if err := router.Run(":" + settings.ServerPort); err != nil {
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
	} else if !errors.Is(err, gorm.ErrRecordNotFound) {
		log.Printf("failed to lookup admin user: %v", err)
		return
	}
	if _, err := authService.CreateUser(settings.AdminEmail, settings.AdminFullName, settings.AdminPassword); err != nil {
		log.Printf("failed to create admin user: %v", err)
		return
	}
	database.Seed("admin user ensured for %s", settings.AdminEmail)
}
