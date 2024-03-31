package mockdb

import (
	"context"
	"time"
	"github.com/go-redis/redis/v8"
)

// NewRedisTokenStore initializes a new RedisTokenStore.
func NewRedisTokenStore(addr string) *RedisTokenStore {
	return &RedisTokenStore{
		client: redis.NewClient(&redis.Options{
			Addr: addr, // e.g., "localhost:6379"
		}),
	}
}

// StoreToken stores a token in Redis with an expiration time.
func (r *RedisTokenStore) StoreToken(token string, expiration time.Duration) error {
	ctx := context.Background()
	return r.client.Set(ctx, token, true, expiration).Err()
}

// IsTokenBlacklisted checks if a token exists in Redis (is blacklisted).
func (r *RedisTokenStore) IsTokenBlacklisted(token string) (bool, error) {
	ctx := context.Background()
	result, err := r.client.Get(ctx, token).Result()
	if err == redis.Nil {
		return false, nil
	}
	return result == "true", err
}
