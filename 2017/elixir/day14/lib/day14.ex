defmodule Day14 do
  def solveA(input) do
    get_grid(input)
    |> Enum.map(fn list -> Enum.count(list, fn x -> x == 1 end) end)
    |> Enum.sum
  end

  def get_grid(input) do
    0..127
    |> Enum.map(fn n -> solve_row(n, input) end)
  end

  def solve_row(n, input) do
    input <> "-" <> Integer.to_string(n)
    |> Day10B.solve(256)
    |> String.split("", trim: true)
    |> Enum.reduce([], fn (c, acc) -> acc ++ to_bin(c) end)
  end

  def to_bin_alt(letter) do
    <<n>> =
      "0" <> letter
      |> Base.decode16!(case: :lower)

    Integer.to_string(n, 2)
    |> String.split("", trim: true)
    |> Enum.map(&String.to_integer/1)
  end
  def to_bin(letter) do
    case letter do
      "0" ->
        [0, 0, 0, 0]
      "1" ->
        [0, 0, 0, 1]
      "2" ->
        [0, 0, 1, 0]
      "3" ->
        [0, 0, 1, 1]
      "4" ->
        [0, 1, 0, 0]
      "5" ->
        [0, 1, 0, 1]
      "6" ->
        [0, 1, 1, 0]
      "7" ->
        [0, 1, 1, 1]
      "8" ->
        [1, 0, 0, 0]
      "9" ->
        [1, 0, 0, 1]
      "a" ->
        [1, 0, 1, 0]
      "b" ->
        [1, 0, 1, 1]
      "c" ->
        [1, 1, 0, 0]
      "d" ->
        [1, 1, 0, 1]
      "e" ->
        [1, 1, 1, 0]
      "f" ->
        [1, 1, 1, 1]
    end
  end
end
