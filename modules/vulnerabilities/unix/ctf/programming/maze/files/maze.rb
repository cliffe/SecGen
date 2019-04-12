#!/usr/bin/env ruby

#
# A node is both a member of a directed graph, and a cell on an x,y
# plane of possibly-connected maze passages.
#
class Node
  attr_accessor :row, :col, :visited, :neighbors, :on_path

  def initialize(row, col)
    @row = row
    @col = col
    @visited = false
    @on_path = false
    @neighbors = {north: nil, east: nil, south: nil, west: nil}
  end

  # Connect this node to another node. The other node can only fit
  # in one of four cardinal directions from this node: North, South,
  # East, or West.
  def connect_to(other)
    if other.row == self.row - 1
      self.neighbors[:north] = other
      other.neighbors[:south] = self
    elsif other.row == self.row + 1
      self.neighbors[:south] = other
      other.neighbors[:north] = self
    elsif other.col == self.col + 1
      self.neighbors[:east] = other
      other.neighbors[:west] = self
    elsif other.col == self.col - 1
      self.neighbors[:west] = other
      other.neighbors[:east] = self
    end
  end
end

#
# A Maze is a container for Nodes, and is responsible for:
#   - generating a maze by connecting unconnected nodes, and
#   - finding a solution through an existing maze of connected nodes.
#
class Maze

  DIRECTIONS = [[-1, 0], [1, 0], [0, -1], [0, 1]]

  def initialize(rows, cols)
    @rows = rows
    @cols = cols

    # Initialize the maze with a bunch of un-connected nodes
    @maze = Array.new(@rows) do |r|
      Array.new(@cols) do |c|
        Node.new(r, c)
      end
    end

    # Pick start and end nodes on opposite ends.
    @start_node = @maze[rand(@rows)][0]
    @end_node = @maze[rand(@rows)][@cols - 1]
  end

  # Generate the maze.
  def generate
    # Make a stack of nodes along our walk
    stack = []

    # Visit the first node
    node = @start_node
    node.visited = true
    stack.push(node)

    # Now keep walking and finding nodes.
    while true
      next_node = get_next_unvisited(node)
      if next_node
        next_node.visited = true
        next_node.connect_to(node)
        stack.push(next_node)
        node = next_node
      else
        node = stack.pop
        break if !node
      end
    end
  end

  def solve
    # Reset visited state on all nodes.
    @maze.each do |row|
      row.each do |node|
        node.visited = false
      end
    end

    stack = []

    # Visit the first node
    node = @start_node
    node.visited = true
    node.on_path = true

    while true
      next_node = get_next_in_graph(node)

      if next_node
        next_node.visited = true
        next_node.on_path = true

        # If we're at the exit, we're done.
        break if next_node == @end_node

        # Otherwise, push onto the stack and keep going.
        stack.push(node)
        node = next_node
      else
        # This would only happen if there were no solution.
        break if stack.size == 0

        # 'node' has no un-visited neighbors, so it can't be on the
        # path.
        node.on_path = false
        node = stack.pop
      end
    end

  end

  # When walking a completed maze, we are doing a random walk of a
  # directed graph, so it's simpler than the random walk to create the
  # maze.
  def get_next_in_graph(node)
    node.neighbors.values.compact.shuffle
        .select {|neighbor| !neighbor.visited }.first
  end

  # When generating a new maze, we need to find the next un-visited
  # neighboring node.
  def get_next_unvisited(node)
    neighbors = []

    DIRECTIONS.each do |dir|
      new_row = node.row + dir[0]
      new_col = node.col + dir[1]

      if new_row >= 0 && new_row < @rows &&
          new_col >= 0 && new_col < @cols &&
          !@maze[new_row][new_col].visited
        neighbors << @maze[new_row][new_col]
      end
    end

    neighbors[rand(neighbors.length)]
  end

  def to_s
    buf = ""

    @maze.each_with_index do |row, idx|
      # Pass one.
      row.each do |node|
        buf << if node.neighbors[:north]
                 "+   "
               else
                 "+---"
               end

        buf << if node.col == @cols - 1
                 "+"
               else
                 ""
               end
      end

      buf << "\r\n"

      # Pass two
      row.each do |node|
        buf << if node.neighbors[:west] || node == @start_node
                 " "
               else
                 "|"
               end

        buf << if node.on_path
                 " @ "
               else
                 "   "
               end

        if node.col == @cols - 1
          buf << if node == @end_node
                   " "
                 else
                   "|"
                 end
        end
      end

      buf << "\r\n"

      # Pass three, if last row
      if idx == @rows - 1
        row.each do |node|
          buf << "+---"
        end
        buf << "+\r\n"
      end
    end

    buf
  end
end


rows = ARGV[0].to_i
cols = ARGV[1].to_i

if rows <= 0 || cols <= 0
  puts "Usage: #{$0} <rows> <cols>"
  exit -1
end

maze = Maze.new(rows, cols)
maze.generate
puts maze
puts "*********"
maze.solve
puts maze