package main

import (
	"fmt"
	"net/http"
)

func main() {
	const port = 8080
	fmt.Printf("Serving current directory on http://localhost:%d/\n", port)
	http.Handle("/", http.FileServer(http.Dir(".")))
	http.ListenAndServe(fmt.Sprintf(":%d", port), nil)
}