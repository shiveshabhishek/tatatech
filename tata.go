package main

import (
	"fmt"
	"net/http"
)

func handler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintln(w, "Welcome to 2022")
	
	userAgent := r.Header.Get("User-Agent")
	fmt.Fprintf(w, "User-Agent: %s", userAgent)
}

func main() {
	http.HandleFunc("/", handler)
	fmt.Println("Server is listening on :8090")
	http.ListenAndServe(":8090", nil)
}
