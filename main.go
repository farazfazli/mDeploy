package main

import (
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"os/exec"
	"regexp"
	"strconv"
	"time"

	"github.com/gorilla/mux"
)

func NewBlogHandler(w http.ResponseWriter, r *http.Request) {
	name := r.FormValue("name")
	repo := r.FormValue("repo")

	seed := rand.NewSource(time.Now().UnixNano())
	rng := rand.New(seed)
	port := rng.Intn(63000) + 2000
	regx := regexp.MustCompile("[^A-Za-z]")

	name = regx.ReplaceAllString(name, "")
	if len(name) >= 1 {
		portString := strconv.Itoa(port)
		dir, err := filepath.Abs(filepath.Dir(os.Args[0]) + "/runmeteor.sh")
		if err != nil {
		fmt.Println(err)
		}
		create, err := exec.Command(dir, name, repo, portString).Output()
		if err != nil {
			fmt.Println(err)
		} else {
			fmt.Println(create)
		}
	}
}

func main() {
	router := mux.NewRouter()
	router.HandleFunc("/new", func(w http.ResponseWriter, r *http.Request) {
		NewBlogHandler(w, r)

	}).Methods("POST")
	fmt.Println("Starting server on port 1337")
	log.Fatal(http.ListenAndServe(":1337", router))
}
