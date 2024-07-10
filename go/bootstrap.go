package main

import (
	"fmt"
	"net/http"
	"os"
	"strings"
)

func main() {
	RUNTIME_API := os.Getenv("AWS_LAMBDA_RUNTIME_API")
	for {
		// get the next invocation
		url := fmt.Sprintf("http://%s/2018-06-01/runtime/invocation/next", RUNTIME_API)
		resp, _ := http.Get(url)
		req_id := resp.Header.Get("Lambda-Runtime-Aws-Request-Id")

		// respond to the request
		url = fmt.Sprintf("http://%s/2018-06-01/runtime/invocation/%s/response", RUNTIME_API, req_id)
		http.Post(
			url,
			"",
			strings.NewReader("Hello, World!"))

		resp.Body.Close()
	}
}
