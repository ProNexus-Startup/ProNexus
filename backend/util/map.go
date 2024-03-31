package util

import "reflect"

func RMEmptyVals(inMap map[string]any) map[string]any {
	outMap := make(map[string]any)
	for key, value := range inMap {
		if !reflect.ValueOf(value).IsZero() {
			outMap[key] = value
		}
	}

	return outMap
}
