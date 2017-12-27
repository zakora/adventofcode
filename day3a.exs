defmodule Day3 do

  def find(target) do
    find(target, 1, "right", 1, 1, 0, 0)
  end

  defp find(target, current, move, remdir, level, x, y) do
    # IO.puts "move: #{move}, rem: #{remdir}, level: #{level} -> {#{x}, #{y}}, sq: #{current}"
    if current == target do
      {x, y}
    else
      next_move =
        if remdir == 1 do
          next(move)
        else
          move
        end

      next_level =
        if move == "down" or move == "up" do
          if remdir == 1 do
            level + 1
          else
            level
          end
        else
          level
        end

      next_remdir =
        if remdir == 1 do
          next_level
        else
          remdir - 1
        end

      case move do
        "up" ->
          find(target, current + 1, next_move, next_remdir, next_level, x, y + 1)
        "down" ->
          find(target, current + 1, next_move, next_remdir, next_level, x, y - 1)
        "left" ->
          find(target, current + 1, next_move, next_remdir, next_level, x - 1, y)
        "right" ->
          find(target, current + 1, next_move, next_remdir, next_level, x + 1, y)
      end
    end
  end

  defp next(move) do
    case move do
      "up"   -> "left"
      "down" -> "right"
      "left" -> "down"
      "right" -> "up"
    end
  end
end

{x, y} = Day3.find(289326)
IO.puts(abs(x) + abs(y))
