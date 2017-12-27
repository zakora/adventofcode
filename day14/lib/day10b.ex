use Bitwise

defmodule Day10B do

  def solve(input, size) do
    input
    |> String.trim
    |> String.to_charlist
    |> Enum.concat([17, 31, 73, 47, 23])
    |> do_round(0..size-1 |> Enum.to_list, 64, 0, 0, size)
    |> to_dense_hash
    |> hex
  end

  def do_round(lengths, list, remaining, position, skip_size, size) do
    if remaining == 0 do
      list
    else
      {list, position, skip_size} = Day10A.tie_knot(lengths, list, position, skip_size, size)
      do_round(lengths, list, remaining - 1, position, skip_size, size)
    end
  end

  def hex(integers) do
    integers
    |> Enum.reduce(<<>>, fn(x, acc) -> acc <> <<x>> end)
    |> Base.encode16(case: :lower)
  end

  def to_dense_hash(sparse_hash) do
    sparse_hash
    |> Enum.chunk_every(16)
    |> Enum.map(fn chunk ->
      Enum.reduce(chunk, fn (x, acc) -> bxor(acc, x) end)
    end)
  end

end
