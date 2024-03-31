package api

import (
	"bytes"
	"encoding/json"
	"fmt"
	"github.com/rpupo63/ProNexus/backend/errs"
	"io"
	"net/http"
)

func sendReq[T, U any](method, url, userID string, requestBody *T) (parsedResp U, err error) {
	requestBytes := []byte{}
	if requestBody != nil {
		requestBytes, err = json.Marshal(requestBody)
		if err != nil {
			return parsedResp, fmt.Errorf("Error marshalling: %v", err)
		}
	}

	request, err := http.NewRequest(method, url, bytes.NewBuffer(requestBytes))
	if err != nil {
		return parsedResp, err
	}

	if userID != "" {
		request.Header.Add("Authorization", "Bearer "+userID)
	}

	response, err := http.DefaultClient.Do(request)
	if err != nil {
		return parsedResp, err
	}
	defer response.Body.Close()

	if response.StatusCode != http.StatusOK {
		bodyBytes, err := io.ReadAll(response.Body)
		if err != nil {
			return parsedResp, fmt.Errorf("Error reading response after non-200 status code, %d: %v", response.StatusCode, err)
		}

		if response.StatusCode == http.StatusUnauthorized {
			return parsedResp, errs.Unauthorized
		}

		errorMsg := fmt.Sprintf("%s. %s", http.StatusText(response.StatusCode), string(bodyBytes))
		return parsedResp, errs.NewApiErr(response.StatusCode, errorMsg)
	}

	if err := json.NewDecoder(response.Body).Decode(&parsedResp); err != nil {
		return parsedResp, fmt.Errorf("Error decoding response: %v", err)
	}

	return parsedResp, nil
}
