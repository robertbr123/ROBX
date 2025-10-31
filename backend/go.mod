module robx-backend

go 1.19

require (
	github.com/gin-contrib/cors v1.7.1
	github.com/gin-gonic/gin v1.9.1
	github.com/golang-jwt/jwt/v5 v5.2.1
	github.com/joho/godotenv v1.5.1
	github.com/mattn/go-sqlite3 v1.14.22
	golang.org/x/crypto v0.13.0
	gorm.io/driver/sqlite v1.5.5
	gorm.io/gorm v1.25.7
)

replace github.com/modern-go/concurrent => github.com/modern-go/concurrent v0.0.0-20180306012644-bacd9c7ef1dd

replace github.com/pelletier/go-toml/v2 => github.com/pelletier/go-toml/v2 v2.0.9
