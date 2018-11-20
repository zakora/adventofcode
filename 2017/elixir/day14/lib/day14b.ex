defmodule Day14B do

  def solveB(input) do
    # load_grid("day14test.in")
    Day14.get_grid(input)
    |> used_squares(0, 0, MapSet.new)
    |> visit(0)
  end

  def load_grid(filename) do
    # Convenience function to restore a map from a previous computation.
    File.stream!(filename, [:utf8], :line)
    |> Enum.map(&parse_line/1)
  end

  def parse_line(line) do
    line
    |> String.trim
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  def used_squares(grid, x, y, set) do
    # Return a MapSet of {x, y} for each used square at (x, y)
    case grid do
      [] ->
        set
      [ [] | other_lines ] ->
        used_squares(other_lines, 0, y + 1, set)
      [ line | other_lines ] ->
        [square | other_squares ] = line
        set =
          if square == 1 do
            MapSet.put(set, {x, y})
          else
            set
          end
        used_squares([other_squares | other_lines], x + 1, y, set)
    end
  end

  def visit(squares, regions) do
    # Return the number of regions formed by the squares
    if Enum.empty? squares do
      regions
    else
      first = Enum.at squares, 0
      seen = bfs_expand MapSet.new([first]), MapSet.new([first]), squares
      squares
      |> MapSet.difference(seen)
      |> visit(regions + 1)
    end
  end

  def bfs_expand(to_visit, visited, squares) do
    # Return a set of all the squares in the same region
    if Enum.empty? to_visit do
      visited
    else
      neighbors =
        adjacent(to_visit)
        |> MapSet.intersection(squares)
        |> MapSet.difference(visited)

      visited = MapSet.union(visited, neighbors)
      squares = MapSet.difference(squares, neighbors)

      bfs_expand(neighbors, visited, squares)
    end
  end

  def adjacent(positions) do
    # Return all adjacent squares to the given list of (x, y) positions.
    # Adjacent squares might not be used squares or even on the grid.
    Enum.reduce(positions, MapSet.new, fn({x, y}, acc) ->
      [{x, y + 1}, {x + 1, y}, {x, y - 1}, {x - 1, y}]
      |> MapSet.new
      |> MapSet.union(acc)
    end)
  end
end
