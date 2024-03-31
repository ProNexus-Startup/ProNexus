package util

import (
	"path/filepath"
	"runtime"
)

func GetProjectRootDir() string {
	_, file, _, _ := runtime.Caller(0)
	return filepath.Join(filepath.Dir(file), "..")
}
