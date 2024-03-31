package database

import (
	"time"
	"github.com/go-redis/redis/v8"
)

// RedisTokenStore manages token storage in Redis.
type RedisTokenStore struct {
	client *redis.Client
}

type TokenStore interface {
    StoreToken(token string, expiration time.Duration) error
    IsTokenBlacklisted(token string) (bool, error)
}
