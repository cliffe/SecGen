package main

import (
	"os"
)

var name = "maze"
var version = "v0.0.2"
var description = "Maze generating and solving program"
var author = "itchyny"

func main() {
	os.Exit(run(os.Args))
}
