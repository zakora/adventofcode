defmodule Day22 do
  def solveA(filename) do
    filename
    |> parse
    |> rec_solveA({0, 0}, :up, 10000, 0)
  end

  def solveB(filename) do
    filename
    |> parse
    |> Map.new(fn k -> {k, :infected} end)
    |> rec_solveB({0, 0}, :up, 10_000_000, 0)
  end

  def parse(filename) do
    lines =
      filename
      |> File.stream!([:utf8], :line)
      |> Stream.map(&String.trim/1)
      |> Enum.map(fn line -> String.split(line, "", trim: true) end)

    midx = round(length(Enum.at(lines, 0)) / 2) - 1
    midy = round(length(lines) / 2) - 1

    Stream.zip(midy..-midy, lines)
    |> Enum.reduce(MapSet.new, fn {y, line}, acc ->
      MapSet.union acc, parse_line(line, -midx, y)
    end)
  end

  def parse_line(line, x, y) do
    line
    |> Enum.reduce({x, MapSet.new}, fn nd, {xx, set} ->
      if nd == "#" do
        {xx + 1, MapSet.put(set, {xx, y})}
      else
        {xx + 1, set}
      end
    end)
    |> elem(1)
  end

  def rec_solveA(_infected, {_x, _y}, _dir, 0, ninfection), do: ninfection
  def rec_solveA(infected, {x, y}, dir, nbursts, ninfection) do
    {infected, dir, ninfection} =
      if MapSet.member? infected, {x, y} do
        {MapSet.delete(infected, {x, y}), turn(dir, :right), ninfection}
      else
        {MapSet.put(infected, {x, y}), turn(dir, :left), ninfection + 1}
      end
    {x, y} = move {x, y}, dir
    rec_solveA(infected, {x, y}, dir, nbursts - 1, ninfection)
  end

  def rec_solveB(_states, {_x, _y}, _dir, 0, ninfection), do: ninfection
  def rec_solveB(states, {x, y}, dir, nbursts, ninfection) do
    {states, dir, ninfection} =
      case Map.get states, {x, y}, :clean do
        :infected ->
          states = Map.replace states, {x, y}, :flagged
          dir = turn(dir, :right)
          {states, dir, ninfection}
        :weakened ->
          states = Map.replace states, {x, y}, :infected
          {states, dir, ninfection + 1}
        :flagged ->
          states = Map.delete states, {x, y}
          dir = turn(dir, :reverse)
          {states, dir, ninfection}
        :clean ->
          states = Map.put states, {x, y}, :weakened
          dir = turn(dir, :left)
          {states, dir, ninfection}
      end
    {x, y} = move {x, y}, dir
    rec_solveB(states, {x, y}, dir, nbursts - 1, ninfection)
  end

  def turn(dir, :right) do
    case dir do
      :left -> :up
      :up -> :right
      :right -> :down
      :down -> :left
    end
  end
  def turn(dir, :left) do
    case dir do
      :left -> :down
      :up -> :left
      :right -> :up
      :down -> :right
    end
  end
  def turn(dir, :reverse) do
    case dir do
      :left -> :right
      :up -> :down
      :right -> :left
      :down -> :up
    end
  end

  def move({x, y}, dir) do
    case dir do
      :left -> {x - 1, y}
      :up -> {x, y + 1}
      :right -> {x + 1, y}
      :down -> {x, y - 1}
    end
  end
end
