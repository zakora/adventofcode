defmodule Day13 do
  def solveA do
    {scanner_positions, scanner_ranges, max_depth} = get_init_state("day13.in")
    rec_solveA(scanner_positions, scanner_ranges, 0, max_depth, 0)
  end

  def solveB do
    {positions, ranges, max_depth} = get_init_state("day13.in")
    rec_solveB(positions, ranges, max_depth, 0)
  end

  def rec_solveB(positions, ranges, max_depth, delay) do
    severity = rec_solveA(positions, ranges, 0, max_depth, 0)
    if delay == 2000 or severity == 0 do
      delay
    else
      positions = move_scanners(positions, ranges)
      rec_solveB(positions, ranges, max_depth, delay + 1)
    end
  end

  def get_init_state(filename) do
    scanner_ranges =
      filename
      |> File.stream!([:utf8], :line)
      |> Enum.reduce(%{}, fn(l, acc) -> parse(l, acc) end)
    scanner_positions =
      scanner_ranges
      |> Map.keys
      |> Enum.zip(Stream.zip Stream.cycle([0]), Stream.cycle([:down]))
      |> Map.new
    max_depth =
      scanner_ranges
      |> Map.keys
      |> Enum.max
    {scanner_positions, scanner_ranges, max_depth}
  end

  def rec_solveA(scanner_positions, scanner_ranges, depth, max_depth, severity) do
    if depth > max_depth do
      severity
    else
      # check if on a scanner
      {pos, _} = Map.get(scanner_positions, depth, {nil, nil})
      range = Map.get(scanner_ranges, depth)
      severity =
        if pos == 0 do
          severity + 1
        else
          severity
        end
      # move scanners
      positions = move_scanners(scanner_positions, scanner_ranges)
      rec_solveA(positions, scanner_ranges, depth + 1, max_depth, severity)
    end
  end

  def parse(line, map) do
    [idx, range] = line
    |> String.trim
    |> String.split(": ")
    |> Enum.map(&String.to_integer/1)
    Map.put map, idx, range
  end

  def move_scanners(positions, ranges) do
    positions
    |> Enum.reduce(%{}, fn ({scanner, state}, acc) ->
      posmax = ranges[scanner] - 1
      {pos, dir} = state
      cond do
        pos == posmax and dir == :down ->
          Map.put(acc, scanner, {pos - 1, :up})
        pos == 0 and dir == :up ->
          Map.put(acc, scanner, {pos + 1, :down})
        dir == :up ->
          Map.put(acc, scanner, {pos - 1, :up})
        dir == :down ->
          Map.put(acc, scanner, {pos + 1, :down})
      end
    end)
  end
end
