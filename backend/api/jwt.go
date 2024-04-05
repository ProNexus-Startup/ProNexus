package api

import (
	"fmt"
	"os" // Import added to use os.Getenv
	"github.com/rpupo63/ProNexus/backend/models"
	"github.com/golang-jwt/jwt/v5"
	"time"
)

type accessClaims struct {
	User models.User `json:"user"`
	jwt.RegisteredClaims
}

func newAccess(user models.User) (string, error) {
    // Retrieve token secret from environment variable
    tokenSecret := os.Getenv("TOKEN_SECRET")
    
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, accessClaims{
		User: user,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(7 * 24 * time.Hour)), // 7 days
		},
	})

	signedToken, err := token.SignedString([]byte(tokenSecret))
	if err != nil {
		return "", fmt.Errorf("error signing token: %v", err)
	}

	return signedToken, nil
}

func getTokenRemainingValidity(tokenString string) (time.Duration, error) {
    // Retrieve token secret from environment variable
    tokenSecret := os.Getenv("TOKEN_SECRET")
    
	token, err := jwt.ParseWithClaims(tokenString, &accessClaims{}, func(token *jwt.Token) (interface{}, error) {
		return []byte(tokenSecret), nil
	})

	if err != nil {
		return 0, err // Token parsing failed or token is invalid
	}

	if claims, ok := token.Claims.(*accessClaims); ok && token.Valid {
		expirationTime := claims.ExpiresAt.Time
		return time.Until(expirationTime), nil
	} else {
		return 0, fmt.Errorf("invalid token")
	}
}

func validateToken(tokenString string) (models.User, error) {
    // Retrieve token secret from environment variable
    tokenSecret := os.Getenv("TOKEN_SECRET")
    
	var noUser models.User // Used to return in case of error

	// Parse the token with the claims.
	token, err := jwt.ParseWithClaims(tokenString, &accessClaims{}, func(token *jwt.Token) (interface{}, error) {
		// Verify the token algorithm...
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return noUser, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}

		// Return the token secret for validation.
		return []byte(tokenSecret), nil
	})

	if err != nil {
		return noUser, err // Token parsing error or invalid token
	}

	if claims, ok := token.Claims.(*accessClaims); ok && token.Valid {
		// Token is valid. You might want to check additional claims if necessary.
		return claims.User, nil
	} else {
		return noUser, fmt.Errorf("invalid token")
	}
}
