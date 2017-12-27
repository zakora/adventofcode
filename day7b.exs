defmodule Day7 do
  def solve(lines) do
    lines
    |> Enum.reduce(%{}, &build_tree/2)
    |> find_odd_weight("mkxke", nil)
    |> elem(1)
  end

  defp build_tree(line, tree) do
    # Returns a map of parent -> children,
    # like %{"azef" => %{weight: 1, children: ["a", "b", "c"]}, ...}

    # parse line
    %{"name" => name, "weight" => weight, "children" => children} =
      Regex.named_captures(~r/^(?<name>[a-z]+) \((?<weight>\d+)\)( \-> (?<children>.*))?$/, line)
    children =
      case children do
        "" -> []
        _  -> String.split(children, ", ")
      end
    weight = String.to_integer(weight)

    # add new program to the tree
    tree
    |> Map.put(name, %{weight: weight, children: children})
  end


  defp find_odd_weight(tree, name, fixed_weight) do
    children = tree[name].children
    if Enum.empty? children do
      {tree[name].weight, fixed_weight}
    else
      children_tuples =
        children
        |> Enum.map(fn child -> find_odd_weight(tree, child, fixed_weight) end)

      children_weights =
        children_tuples
        |> Enum.map(fn tuple -> elem(tuple, 0) end)

      fixed_weight =
        case same_weights? children_tuples do
          :ok ->
            fixed_weight
          {:fixed_weight, fw} ->
            fw
          {:diff, diff, idx} ->
            child =
              children
              |> List.to_tuple
              |> elem(idx)
            tree[child].weight - diff
        end

      {Enum.sum(children_weights) + tree[name].weight, fixed_weight}
    end
  end

  def same_weights?(ws) do
    fixed_weight =
      ws
      |> Enum.map(fn x -> elem(x, 1) end)
      |> Enum.find(:none, fn x -> x != nil end)
    {odd, diff, idx} =
      ws
      |> Enum.map(fn x -> elem(x, 0) end)
      |> any_odd?
    case {fixed_weight, odd, diff, idx} do
      {:none, :none, _, _} ->
        :ok
      {:none, :odd, diff, idx} ->
        {:diff, diff, idx}
      {fw, _, _, _} ->
        {:fixed_weight, fw}
    end
  end

  defp any_odd?(enum) do
    # returns {:none, nil, nil} if all enum values are the same,
    # otherwise {:odd, y - x, idx}, where x is the common value in the enum
    # and y is the odd one; idx is the index of the odd value.
    case Enum.uniq(enum) do
      [_] ->
        {:none, nil, nil}
      [first, second] ->
        cfirst = Enum.count(enum, fn x -> x == first end)
        csecond = Enum.count(enum, fn x -> x == second end)

        cond do
          cfirst == 1 ->
            # x = second, y = first
            {:odd, first - second, Enum.find_index(enum, fn y -> y == first end)}
          csecond == 1 ->
            # x = first, y = second
            {:odd, second - first, Enum.find_index(enum, fn y -> y == second end)}
        end
    end
  end
end

File.stream!("day7.txt", [:utf8], :line)
|> Day7.solve
|> IO.puts
