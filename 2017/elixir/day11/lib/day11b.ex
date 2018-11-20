defmodule Day11B do
  def solve do
    File.read!("day11.txt")
    |> String.trim
    |> String.split(",")
    |> dist(0, 0, 0, 0)
  end

  def dist(directions, furthest, x, y, z) do
    if Enum.empty? directions do
      furthest
    else
      [dir | tail] = directions
      furthest =
        [x, y, z]
        |> Enum.map(fn x -> abs(x) end)
        |> Enum.max
        |> max(furthest)
      case dir do
        "n" ->
          dist(tail, furthest, x - 1, y, z + 1)
        "ne" ->
          dist(tail, furthest, x - 1, y + 1, z)
        "se" ->
          dist(tail, furthest, x, y + 1, z - 1)
        "s" ->
          dist(tail, furthest, x + 1, y, z - 1)
        "sw" ->
          dist(tail, furthest, x + 1, y - 1, z)
        "nw" ->
          dist(tail, furthest, x, y - 1, z + 1)
      end
    end
  end
end
