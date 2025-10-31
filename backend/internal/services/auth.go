package services

import (
	"errors"
	"time"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"

	"github.com/golang-jwt/jwt/v5"

	"robx-backend/internal/config"
	"robx-backend/internal/models"
)

// AuthService handles authentication flows.
type AuthService struct {
	DB       *gorm.DB
	Settings config.Settings
}

// HashPassword hashes user password.
func (s AuthService) HashPassword(password string) (string, error) {
	bytes, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	return string(bytes), err
}

// VerifyPassword compares plain password with hashed password.
func (s AuthService) VerifyPassword(hash, password string) bool {
	return bcrypt.CompareHashAndPassword([]byte(hash), []byte(password)) == nil
}

// CreateAccessToken generates JWT token for a user.
func (s AuthService) CreateAccessToken(sub string) (string, error) {
	claims := jwt.MapClaims{
		"sub": sub,
		"exp": time.Now().Add(s.Settings.AccessTokenExpire).Unix(),
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(s.Settings.SecretKey))
}

// ParseToken validates a JWT token and returns the claims.
func (s AuthService) ParseToken(tokenString string) (*jwt.Token, error) {
	return jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, errors.New("invalid signing method")
		}
		return []byte(s.Settings.SecretKey), nil
	})
}

// GetUserByEmail retrieves a user from DB.
func (s AuthService) GetUserByEmail(email string) (*models.User, error) {
	var user models.User
	result := s.DB.Where("email = ?", email).First(&user)
	if result.Error != nil {
		return nil, result.Error
	}
	return &user, nil
}

// CreateUser persists a new user after hashing password.
func (s AuthService) CreateUser(email, fullName, password string) (*models.User, error) {
	hash, err := s.HashPassword(password)
	if err != nil {
		return nil, err
	}
	user := models.User{
		Email:          email,
		FullName:       fullName,
		HashedPassword: hash,
	}
	if err := s.DB.Create(&user).Error; err != nil {
		return nil, err
	}
	return &user, nil
}
