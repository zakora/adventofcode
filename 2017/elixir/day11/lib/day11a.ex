defmodule Day11A do
  def solve do
    File.read!("day11.txt")
    |> String.trim
    |> String.split(",")
    |> dist(0, 0, 0)
  end

  def dist(directions, x, y, z) do
    if Enum.empty? directions do
      [x, y, z]
      |> Enum.map(fn x -> abs(x) end)
      |> Enum.max
    else
      [dir | tail] = directions
      case dir do
        "n" ->
          dist(tail, x - 1, y, z + 1)
        "ne" ->
          dist(tail, x - 1, y + 1, z)
        "se" ->
          dist(tail, x, y + 1, z - 1)
        "s" ->
          dist(tail, x + 1, y, z - 1)
        "sw" ->
          dist(tail, x + 1, y - 1, z)
        "nw" ->
          dist(tail, x, y - 1, z + 1)
      end
    end
  end
end
