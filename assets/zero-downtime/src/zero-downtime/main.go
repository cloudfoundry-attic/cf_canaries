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

  http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintf(w, "Zero downtime canary sings")
  })

  log.Fatal(http.ListenAndServe(*addr, nil))
}
