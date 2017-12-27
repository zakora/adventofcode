defmodule Day19 do
  # looking at input, letters should be: H ... Z ?
  # 2D Map with origin at top left, meaning going down increases y

  @alphabet MapSet.new(["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"])

  @valid MapSet.union(@alphabet, MapSet.new(["-", "|", "+"]))

  def solve(filename) do
    map = to_map filename
    start_x =
      map
      |> elem(0)
      |> get_start_x
    xmax = map |> elem(0) |> tuple_size
    ymax = map |> tuple_size

    {letters, counter} = travel(map, xmax - 1, ymax - 1, {start_x, 0}, :down, [], 0)
    {letters |> Enum.join(""), counter}
  end

  def to_map(filename) do
    filename
    |> File.stream!([:utf8], :line)
    |> Enum.map(fn line ->
      line
      |> String.trim("\n")
      |> String.split("", trim: true)
      |> List.to_tuple
    end)
    |> List.to_tuple
  end

  def get_start_x(tuple) do
    tuple
    |> Tuple.to_list
    |> Enum.find_index(fn x -> x == "|" end)
  end

  def travel(map, xmax, ymax, {x, y}, _dir, letters, counter)
  when x < 0 or x > xmax or y < 0 or y > ymax  # out of the grid
    or map |> elem(y) |> elem(x) == " " do     # out of path
    {letters, counter}
  end
  def travel(map, xmax, ymax, {x, y}, dir, letters, counter) do
    p = map |> elem(y) |> elem(x)
    cond do
      p == "+" ->
        {ndir, nx, ny} = next_dir(map, xmax, ymax, {x, y}, dir)
        travel(map, xmax, ymax, {nx, ny}, ndir, letters, counter + 1)
      true ->
        letters =
          if p in @alphabet do
            letters ++ [p]
          else
            letters
          end
        {nx, ny} = move(dir, x, y)
        travel(map, xmax, ymax, {nx, ny}, dir, letters, counter + 1)
    end
  end

  def next_dir(map, xmax, ymax, {x, y}, dir) do
    moves =
      cond do  # possible moves
        dir == :up or dir == :down ->
          [{:left, x - 1, y}, {:right, x + 1, y}]
        dir == :left or dir == :right ->
          [{:down, x, y + 1}, {:up, x, y - 1}]
      end

    moves
    |> Enum.find(fn {_d, nx, ny} ->
      nx >= 0 and nx <= xmax
      and ny >= 0 and ny <= ymax
      and (map |> elem(ny) |> elem(nx)) in @valid
    end)
  end

  def move(dir, x, y) do
    case dir do
      :up ->
        {x, y - 1}
      :down ->
        {x, y + 1}
      :left ->
        {x - 1, y}
      :right ->
        {x + 1, y}
    end
  end
end
