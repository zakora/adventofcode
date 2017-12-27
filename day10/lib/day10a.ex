defmodule Day10A do
  def solve(size) do
    File.read!("day10.txt")
    |> String.trim
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> tie_knot(0..size-1 |> Enum.to_list, 0, 0, size)
    |> elem(0)
    |> (fn enum -> Enum.at(enum, 0) * Enum.at(enum, 1) end).()
  end

  def tie_knot(lengths, list, position, skip_size, size) do
    if Enum.empty? lengths do
      {list, position, skip_size}
    else
      [len | tail] = lengths
      sublist = sub(list, [], position, len, size)
      reverse = Enum.reverse(sublist)
      list = replace(list, reverse, position, size)
      position = position + len + skip_size
      skip_size = skip_size + 1
      tie_knot(tail, list, position, skip_size, size)
    end
  end

  def sub(list, sublist, position, len, size) do
    if len == 0 do
      sublist
    else
      x = Enum.at(list, rem(position, size))
      sublist = sublist ++ [x]
      sub(list, sublist, position + 1, len - 1, size)
    end
  end

  def replace(list, revlist, position, size) do
    if Enum.empty? revlist do
      list
    else
      [x | tail ] = revlist
      list = List.replace_at(list, rem(position, size), x)
      replace(list, tail, position + 1, size)
    end
  end

end
