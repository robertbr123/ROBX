package middleware

import (
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"

	"robx-backend/internal/services"
)

// AuthMiddleware validates JWT token and attaches email to context.
func AuthMiddleware(authService services.AuthService) gin.HandlerFunc {
	return func(c *gin.Context) {
		header := c.GetHeader("Authorization")
		if header == "" {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"detail": "Token ausente"})
			return
		}
		parts := strings.SplitN(header, " ", 2)
		if len(parts) != 2 || !strings.EqualFold(parts[0], "Bearer") {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"detail": "Formato inválido de token"})
			return
		}

		token, err := authService.ParseToken(parts[1])
		if err != nil || !token.Valid {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"detail": "Token inválido"})
			return
		}

		claims, ok := token.Claims.(jwt.MapClaims)
		if !ok {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"detail": "Token inválido"})
			return
		}

		email, _ := claims["sub"].(string)
		if email == "" {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"detail": "Token inválido"})
			return
		}

		c.Set("user_email", email)
		c.Next()
	}
}
