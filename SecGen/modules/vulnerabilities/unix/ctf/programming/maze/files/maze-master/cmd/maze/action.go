package main

import (
	"fmt"
	"math/rand"
	"os"

	"github.com/codegangsta/cli"
	"github.com/itchyny/maze"
	"github.com/nsf/termbox-go"
)

func action(ctx *cli.Context) error {
	err := termbox.Init()
	if err != nil {
		fmt.Fprintf(os.Stderr, err.Error())
		return nil
	}
	config, errors := makeConfig(ctx)
	if errors != nil {
		hasErr := false
		termbox.Close()
		for _, err := range errors {
			if err.Error() != "" {
				fmt.Fprintf(os.Stderr, err.Error()+"\n")
				hasErr = true
			}
		}
		if hasErr {
			fmt.Fprintf(os.Stderr, "\n")
		}
		cli.ShowAppHelp(ctx)
		return nil
	}

	maze := createMaze(config)
	if config.Interactive {
		defer termbox.Close()
		interactive(maze, config.Format)
	} else {
		termbox.Close()
		if config.Image {
			maze.PrintImage(config.Output, config.Format, config.Scale)
		} else {
			maze.Print(config.Output, config.Format)
		}
	}
	return nil
}

func createMaze(config *Config) *maze.Maze {
	rand.Seed(config.Seed)
	maze := maze.NewMaze(config.Height, config.Width)
	maze.Start = config.Start
	maze.Goal = config.Goal
	maze.Cursor = config.Start
	maze.Generate()
	if config.Solution {
		maze.Solve()
	}
	return maze
}
