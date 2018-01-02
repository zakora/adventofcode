defmodule Day24 do
  def solveA(filename) do
    {starters, components} = parse filename
    bridges(starters, components)
    |> Enum.reduce(0, fn bridge, acc ->
      val = Enum.reduce bridge, 0, fn {porta, portb}, acc -> acc + porta + portb end
      if val > acc, do: val, else: acc
    end)
  end

  def solveB(filename) do
    {starters, components} = parse filename
    {_, max} =
      bridges(starters, components)
      |> Enum.reduce({0, 0}, fn bridge, {size, val} ->
        new_size = length(bridge)
        if new_size > size do
          val = Enum.reduce bridge, 0, fn {porta, portb}, acc -> acc + porta + portb end
          {new_size, val}
        else
          {size, val}
        end
      end)
    max
  end

  def parse(filename) do
    lines =
      filename
      |> File.stream!([:utf8], :line)
      |> Stream.map(&String.trim/1)
      |> Stream.map(fn line ->
        String.split(line, "/")
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple
      end)

      Enum.reduce lines, {MapSet.new, MapSet.new}, fn {porta, portb}, {starters, components} ->
        starters =
          cond do
            portb == 0 ->
              MapSet.put starters, {porta, portb}
            porta == 0 ->
              MapSet.put starters, {portb, porta}
            true ->
              starters
          end
        components = MapSet.union components, MapSet.new([{porta, portb}, {portb, porta}])
        {starters, components}
      end
  end

  def bridges(starters, components) do
    Enum.reduce starters, MapSet.new, fn {porta, portb}, acc ->
      components = MapSet.difference components, MapSet.new([{porta, portb}, {portb, porta}])
      MapSet.union acc, bridges({porta, portb}, [], components)
    end
  end
  def bridges(component, bridge, remaining) do
    {_porta, portb} = component 
    {a, _} = Enum.at bridge, 0, {portb, nil}
    if portb == a do
      bridge = [component | bridge]
      children_set =
        Enum.reduce remaining, MapSet.new, fn {porta, portb}, acc ->
          remaining = MapSet.difference remaining, MapSet.new([{porta, portb}, {portb, porta}])
          MapSet.union acc, bridges({porta, portb}, bridge, remaining)
        end
      MapSet.put children_set, bridge
    else
      MapSet.new
    end
  end
end
