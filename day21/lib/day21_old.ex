defmodule Day21Old do
  @start [[".", "#", "."],
          [".", ".", "#"],
          ["#", "#", "#"]]

  def solveA(filename), do: solve filename, 5
  def solveB(filename), do: solve filename, 18
  def solve(filename, niter) do
    book = parse filename
    grid = rec_solveA @start, niter, book
    grid
    |> List.flatten
    |> Enum.count(fn x -> x == "#" end)
  end

  def parse(filename) do
    filename
    |> File.stream!([:utf8], :line)
    |> Enum.map(&String.trim/1)
    |> Enum.reduce(%{}, fn line, acc ->
      {k, v} = get_rule line
      Map.put acc, k, v
    end)
  end

  def get_rule(line) do
    [left, right] = String.split(line, " => ")
    {to_square(left), to_square(right)}
  end

  def to_square(pattern) do
    pattern
    |> String.split("/")
    |> Enum.map(fn line -> String.split(line, "", trim: true) end)
  end

  def patterns(pixels) do
    [pixels | rotations(pixels)]
    |> Enum.reduce(MapSet.new, fn block, acc ->
      MapSet.union acc, MapSet.new([fliph(block), flipv(block)])
    end)
  end

  def fliph(pixels), do: Enum.reverse pixels
  def flipv(pixels), do: Enum.map pixels, &Enum.reverse/1
  def rotate(pixels) do
    size = pixels |> length
    empty = List.duplicate [], size
    rec_rotate(pixels, empty)
  end
  def rec_rotate([], output), do: output
  def rec_rotate(input, output) do
    [line | tail] = input

    output =
      Enum.zip(line, output)
      |> Enum.map(fn {pixel, rline} -> [pixel | rline] end)

    rec_rotate(tail, output)
  end
  def rotations(pixels) do
    r1 = rotate(pixels)
    r2 = rotate(r1)
    r3 = rotate(r2)
    [r1, r2, r3]
  end

  def print(pixels) do
    pixels
    |> Enum.map(fn line -> Enum.join line, "" end)
    |> Enum.join("\n")
    |> IO.write
    IO.write("\n")
  end

  def rec_solveA(grid, 0, _book), do: grid
  def rec_solveA(grid, iter, book) do
    width = length grid
    blocks =
      if rem(width, 2) == 0 do
        divide(grid, 2, width)
      else
        divide(grid, 3, width)
      end
    converted = Enum.map(blocks, fn b -> convert b, book end)
    nblocks = length converted
    grid =
      if rem(width, 2) == 0 do
        assemble(converted, 0, 0, [], 3, nblocks)
      else
        assemble(converted, 0, 0, [], 4, nblocks)
      end
    IO.puts "iter: #{iter}"
    IO.puts "grid: #{inspect grid}"
    rec_solveA grid, iter - 1, book
  end

  def divide(grid, chunk_size, width) do
    grid
    |> Enum.map(fn line -> Enum.chunk_every line, chunk_size end)
    |> rec_divide(0, 0, [], chunk_size, width)
  end

  def rec_divide(grid, x, y, res, chunk_size, width) do
    cond do
      y == width ->
        res
      x == width / chunk_size ->
        rec_divide(grid, 0, y + chunk_size, res, chunk_size, width)
      true ->
        res =
          res ++ [Enum.map(0 .. chunk_size - 1, fn n ->
            grid |> Enum.at(y + n) |> Enum.at(x)
          end)]
        rec_divide(grid, x + 1, y, res, chunk_size, width)
    end
  end

  def convert(block, book) do
    match =
      patterns(block)
      |> Enum.find(fn p -> Map.has_key? book, p end)
    Map.get book, match
  end

  def assemble(grid, x, y, res, chunk_size, nblocks) do
    cond do
      y == nblocks ->
        res
      x == chunk_size ->
        assemble(grid, 0, y + round(:math.sqrt(nblocks)), res, chunk_size, nblocks)
      true ->
        block =
          Enum.map(0 .. round(:math.sqrt(nblocks) - 1), fn n ->
              grid |> Enum.at(y + n) |> Enum.at(x)
            end)
          |> Enum.concat
        res = res ++ [block]
        assemble(grid, x + 1, y, res, chunk_size, nblocks)
    end
  end

end
