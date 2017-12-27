defmodule Day1 do

  def solve(captcha) do
    captcha
    |> String.split("")
    |> Enum.reject(fn (x) -> x == "\n" or x == "" end)
    |> Enum.map(&String.to_integer/1)
    |> compute
  end

  defp compute(xs) do
    rec_compute(xs, length(xs), 0, 0)
  end

  defp rec_compute(xs, size, index, acc) do
    if index == size do
      acc
    else
      first = Enum.at(xs, index)
      second = Enum.at(xs, rem(index + div(size, 2), size))

      acc =
        if first == second do
          acc + first
        else
          acc
        end

      rec_compute(xs, size, index + 1, acc)
    end
  end

end

File.read!("day1.txt")
|> Day1.solve
|> IO.puts
