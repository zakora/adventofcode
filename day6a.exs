defmodule Day6 do

  def solve(banks) do
    recur(banks, MapSet.new, 0, length(banks))
  end

  defp recur(banks, seen_banks, steps, size) do
    if banks in seen_banks do
      steps
    else
      seen_banks = MapSet.put(seen_banks, banks)
      {index, value} = find_max(banks)
      banks =
        banks
        |> List.replace_at(index, 0)
        |> spread(index + 1, value, size)
      recur(banks, seen_banks, steps + 1, size)
    end
  end

  defp find_max(list) do
    # return {idx, value} of the max from the list
    [head | _ ] = list
    rec_find_max(list, 0, head, 0)
  end

  defp rec_find_max(list, index, value, step) do
    if Enum.empty?(list) do
      {index, value}
    else
      [head | tail ] = list
      {index, value} =
        if head > value do
          {step, head}
        else
          {index, value}
        end
      rec_find_max(tail, index, value, step + 1)
    end
  end

  defp spread(list, idx, value, size) do
    if value == 0 do
      list
    else
      idx = rem(idx, size)
      list = List.update_at(list, idx, fn (x) -> x + 1 end)
      spread(list, idx + 1, value - 1, size)
    end
  end

end

File.read!("day6.txt")
|> String.split
|> Enum.map(&String.to_integer/1)
|> Day6.solve
|> IO.puts
