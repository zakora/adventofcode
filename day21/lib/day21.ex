defmodule Day21 do
  # Faster version for Day 21 (~100-1000x time faster).
  # Inspired by Saša Jurić version: https://gist.github.com/sasa1977/1246dc75886faf7da6b7956d158c2420
  # This version uses boolean lists instead of binaries and makes heavy use of
  # streams to transform the pixel grid.

  def solveA(filename), do: solve filename, 5
  def solveB(filename), do: solve filename, 18
  def solve(filename, niter) do
    rules = parse filename

    {3, ".#./..#/###" |> to_bin_square}
    |> Stream.iterate(&iter(&1, rules))
    |> Enum.at(niter)
    |> count
  end

  def iter({size, pixels}, rules) do
    square_size = if rem(size, 2) == 0, do: 2, else: 3
    next_square_size = if square_size == 2, do: 3, else: 4
    nsquares_by_row = div size, square_size

    pixels =
      pixels
      |> squares(size, square_size, nsquares_by_row)
      |> Stream.map(&Map.fetch!(rules, &1))
      |> merge(next_square_size, nsquares_by_row)
    {next_square_size * nsquares_by_row, pixels}
  end

  def count({_size, pixels}) do
    Enum.count pixels, fn x -> x end
  end

  def squares(pixels, size, square_size, nsquares_by_row) do
    pixels
    |> Stream.chunk_every(square_size)
    |> Stream.chunk_every(size)
    |> Stream.map(&Stream.chunk_every(&1, nsquares_by_row))
    |> Stream.flat_map(&Stream.zip/1)
    |> Stream.map(fn tuple -> tuple |> Tuple.to_list |> Enum.concat end)
  end

  def merge(squares, square_size, nsquares_by_row) do
    squares
    |> Stream.chunk_every(nsquares_by_row)
    |> Stream.flat_map(&merge_row(&1, square_size))
  end

  def merge_row(row, square_size) do
    row
    |> Stream.map(&Stream.chunk_every(&1, square_size))
    |> Stream.zip
    |> Stream.flat_map(fn tuple -> tuple |> Tuple.to_list |> Stream.concat end) 
  end

  def parse(filename) do
    filename
    |> File.stream!
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split &1, " => ")
    |> Stream.map(fn line -> Enum.map line, &to_bin_square/1 end)
    |> Enum.map(&List.to_tuple/1)
    |> Map.new
    |> enhance
  end

  def enhance(map) do
    map
    |> Map.keys
    |> Enum.reduce(map, fn square, acc ->
      enhanced_square = Map.fetch! map, square
      square
      |> variations
      |> Stream.zip(Stream.cycle [enhanced_square])
      |> Map.new
      |> Map.merge(acc)
    end)
  end

  def variations(square) do
    square
    |> rotations
    |> Enum.flat_map(fn sq -> [sq, fliph(sq), flipv(sq)] end)
  end

  def rotations(square) do
    rot1 = rotate square
    rot2 = rotate rot1
    rot3 = rotate rot2
    [square, rot1, rot2, rot3]
  end

  def rotate([a, b,
              c, d]) do
    [c, a,
     d, b]
  end
  def rotate([a, b, c,
              d, e, f,
              g, h, i]) do
    [g, d, a,
     h, e, b,
     i, f, c]
  end
  def flipv([a, b,
             c, d]) do
    [b, a,
     d, c]
  end
  def flipv([a, b, c,
             d, e, f,
             g, h, i]) do
    [c, b, a,
     f, e, d,
     i, h, g]
  end
  def fliph([a, b,
             c, d]) do
    [c, d,
     a, b]
  end
  def fliph([a, b, c,
             d, e, f,
             g, h, i]) do
   [g, h, i,
    d, e, f,
    a, b, c]
  end

  def to_bin_square(square) do
    square
    |> String.codepoints
    |> Stream.reject(fn c -> c == "/" end)
    |> Enum.map(fn c ->
      case c do
        "." -> false
        "#" -> true
      end
    end)
  end
end
