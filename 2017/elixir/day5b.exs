require Logger

defmodule Day5 do
  def solve(instructions) do
    bound = tuple_size(instructions)

    recur(instructions, bound, 0, 0)
  end

  defp recur(instructions, bound, idx, steps) do
    if idx >= bound or idx < 0 do
      steps
    else
      value = elem(instructions, idx)
      incr =
        if value > 2 do
          -1
        else
          1
        end
      instructions = put_elem(instructions, idx, value + incr)
      idx = idx + value
      recur(instructions, bound, idx, steps + 1)
    end
  end

end

File.read!("day5.txt")
|> String.split()
|> Enum.map(&String.to_integer/1)
|> List.to_tuple
|> Day5.solve
|> IO.puts
