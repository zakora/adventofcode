require Logger

defmodule Day3 do

  def solve(target) do
    explore(target, 1, %{{0, 0} => 1}, 0, 0, "right", 1, 1)
  end

  defp explore(target, current, grid, x, y, move_to, moves_left, move_level) do
    if current > target do
      current
    else
      Logger.debug(current)
      # Move to next spiral step (x, y)
      {x, y} = move(x, y, move_to)
      # Compute grid & new current value
      {grid, current} = sum_grid(grid, x, y)
      # Compute next move
      {move_to, moves_left, move_level} = next_move(move_to, moves_left, move_level)
      explore(target, current, grid, x, y, move_to, moves_left, move_level)
    end
  end

  defp sum_grid(grid, x, y) do
    value = 0

    value = value + Map.get(grid, {x + 1, y}, 0)
    value = value + Map.get(grid, {x + 1, y + 1}, 0)
    value = value + Map.get(grid, {x, y + 1}, 0)
    value = value + Map.get(grid, {x - 1, y + 1}, 0)
    value = value + Map.get(grid, {x - 1, y}, 0)
    value = value + Map.get(grid, {x - 1, y - 1}, 0)
    value = value + Map.get(grid, {x, y - 1}, 0)
    value = value + Map.get(grid, {x + 1, y - 1}, 0)

    grid = Map.put(grid, {x, y}, value)
    {grid, value}
  end

  defp move(x, y, move_to) do
    case move_to do
      "right" ->
        {x + 1, y}
      "left" ->
        {x - 1, y}
      "up" ->
        {x, y + 1}
      "down" ->
        {x, y - 1}
    end
  end

  defp next_move(to, remaining, level) do
    case {to, remaining} do
      {"up", 1} ->
        {"left", level + 1, level + 1}
      {"down", 1} ->
        {"right", level + 1, level + 1}
      {_, 1} ->
        {spiral_next(to), level, level}
      _ ->
        {to, remaining - 1, level}
    end
  end

  defp spiral_next(dir) do
    case dir do
      "right" ->
        "up"
      "up" ->
        "left"
      "left" ->
        "down"
      "down" ->
        "right"
    end
  end

end

IO.puts Day3.solve(289326)
