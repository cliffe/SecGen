# maze [![Travis Build Status](https://travis-ci.org/itchyny/maze.svg?branch=master)](https://travis-ci.org/itchyny/maze)

![maze](https://raw.githubusercontent.com/wiki/itchyny/maze/image/maze1.gif)

## Usage
The `maze` command without the arguments prints the random maze to the standard output.
```sh
maze
```
![maze](https://raw.githubusercontent.com/wiki/itchyny/maze/image/maze6.gif)

We can play the maze on the terminal with `--interactive`.
```sh
maze --interactive
```
![maze](https://raw.githubusercontent.com/wiki/itchyny/maze/image/maze2.gif)

The `--format color` is a good option to print the colored maze. Also we can specify the size of the maze with `--width` and `--height`.
```sh
maze --width 20 --height 10 --format color
```
![maze](https://raw.githubusercontent.com/wiki/itchyny/maze/image/maze3.gif)

We can toggle the solution with the `s` key.
![maze](https://raw.githubusercontent.com/wiki/itchyny/maze/image/maze4.gif)

If we change the font size of the terminal smaller, we get a large maze.
![maze](https://raw.githubusercontent.com/wiki/itchyny/maze/image/maze5.gif)

## Installation
### Homebrew
```bash
 $ brew install itchyny/maze/maze
```

### Download binary from GitHub Releases
[Releases・itchyny/maze - GitHub](https://github.com/itchyny/maze/releases)

### Build from source
```bash
 $ go get -u github.com/itchyny/maze/cmd/maze
```

## Bug Tracker
Report bug at [Issues・itchyny/maze - GitHub](https://github.com/itchyny/maze/issues).

## Author
itchyny (https://github.com/itchyny)

## License
This software is released under the MIT License, see LICENSE.

## Special thanks
Special thanks to the [termbox-go](https://github.com/nsf/termbox-go) library.

## References
- [Maze generation algorithm - Wikipedia, the free encyclopedia](https://en.wikipedia.org/wiki/Maze_generation_algorithm)
- [Maze solving algorithm - Wikipedia, the free encyclopedia](https://en.wikipedia.org/wiki/Maze_solving_algorithm)
- [lunixbochs/maze: Maze generation and salvation](https://github.com/lunixbochs/maze)
- [willfrew/maze-generation: Some maze generation algorithms written in Go](https://github.com/willfrew/maze-generation)
