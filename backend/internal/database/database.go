package database

import (
	"fmt"
	"log"
	"strings"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

// Connect establishes a GORM connection using a DSN string.
func Connect(dsn string) *gorm.DB {
	// Accept both sqlite:///path.db and sqlite://path.db
	clean := strings.TrimPrefix(dsn, "sqlite://")
	clean = strings.TrimPrefix(clean, "sqlite:")
	clean = strings.TrimPrefix(clean, "file:")
	if clean == "" {
		clean = "./robx.db"
	}

	db, err := gorm.Open(sqlite.Open(clean), &gorm.Config{})
	if err != nil {
		log.Fatalf("failed to connect to database: %v", err)
	}
	return db
}

// Migrate performs database schema migrations.
func Migrate(db *gorm.DB, models ...interface{}) {
	if err := db.AutoMigrate(models...); err != nil {
		log.Fatalf("failed to migrate database: %v", err)
	}
}

// Seed logs a message when seeding default records.
func Seed(message string, args ...interface{}) {
	log.Printf(fmt.Sprintf("[seed] %s", message), args...)
}
