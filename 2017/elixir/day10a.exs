require IEx

defmodule Day10 do
  def solve(lengths) do
    IEx.pry
    1
  end
end

File.read!("day10.txt")
|> String.trim
|> String.split(",")
|> Enum.map(&String.to_integer/1)
|> Day10.solve
