defmodule Day12 do
  def solveA do
    File.stream!("day12.in", [:utf8], :line)
    |> Enum.reduce(%{}, fn (line, acc) -> Day12.parse(line, acc) end)
    |> Day12.connected(0)
    |> MapSet.size
  end

  def solveB do
    mapping =
      File.stream!("day12.in", [:utf8], :line)
      |> Enum.reduce(%{}, fn (line, acc) -> Day12.parse(line, acc) end)
    programs =
      mapping
      |> Map.keys
      |> MapSet.new
    connected_count(mapping, programs, 0)
  end

  def connected_count(mapping, remaining, count) do
    if Enum.empty? remaining do
      count
    else
      first = Enum.at(remaining, 0)
      group = connected(mapping, first)
      remaining = MapSet.difference(remaining, group)
      connected_count(mapping, remaining, count + 1)
    end
  end

  def parse(line, map) do
    [nd, next] =
      line
      |> String.trim
      |> String.split(" <-> ")
    nd = String.to_integer nd
    next =
      next
      |> String.split(", ")
      |> Enum.map(&String.to_integer/1)
      |> MapSet.new
    Map.put(map, nd, MapSet.new next)
  end

  def connected(mapping, nd) do
    rec_connected(mapping, MapSet.new([nd]), MapSet.new([nd]))
  end

  def rec_connected(mapping, nodes, seen) do
    if Enum.empty? nodes do
      nodes
    else
      next = Enum.reduce(nodes, MapSet.new, fn (n, acc) ->
        acc
        |> MapSet.union(mapping[n])
        |> MapSet.difference(seen)
      end)
      seen = MapSet.union(seen, next)
      MapSet.union(nodes, rec_connected(mapping, next, seen))
    end
  end
end
