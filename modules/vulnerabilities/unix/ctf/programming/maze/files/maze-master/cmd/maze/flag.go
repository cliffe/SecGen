package main

import (
	"github.com/codegangsta/cli"
)

var flags = []cli.Flag{
	cli.StringFlag{
		Name:  "width",
		Usage: "The width of the maze",
	},
	cli.StringFlag{
		Name:  "height",
		Usage: "The height of the maze",
	},
	cli.StringFlag{
		Name:  "start",
		Usage: "The start coordinate",
	},
	cli.StringFlag{
		Name:  "goal",
		Usage: "The goal coordinate",
	},
	cli.BoolFlag{
		Name:  "interactive",
		Usage: "Play the maze interactively",
	},
	cli.BoolFlag{
		Name:  "solution",
		Usage: "Print the maze with the solution",
	},
	cli.StringFlag{
		Name:  "format",
		Usage: "Output format, `default` or `color`",
	},
	cli.StringFlag{
		Name:  "output, o",
		Usage: "Output file name",
	},
	cli.BoolFlag{
		Name:  "image",
		Usage: "Generate image",
	},
	cli.IntFlag{
		Name:  "scale",
		Usage: "Scale of the image",
		Value: 1,
	},
	cli.StringFlag{
		Name:  "seed",
		Usage: "The random seed",
	},
	cli.BoolFlag{
		Name:  "help, h",
		Usage: "Shows the help of the command",
	},
}
