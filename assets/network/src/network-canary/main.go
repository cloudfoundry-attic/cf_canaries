package main

import (
	"flag"
	"fmt"
	"log"
	"net/http"
)

var addr = flag.String("addr", ":8000", "http service address")

func main() {
	flag.Parse()

	http.HandleFunc("/", pingGoogle)

	log.Fatal(http.ListenAndServe(*addr, nil))
}

func pingGoogle(w http.ResponseWriter, r *http.Request) {
	res, err := http.Get("http://google.com/")
	if err != nil {
		panic("Canary croaked")
	}

	res.Body.Close()
	fmt.Fprintf(w, "Canary sings")
}
