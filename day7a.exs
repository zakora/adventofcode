defmodule Day7 do
  def solve(lines) do
    lines
    |> Enum.map(&parse_prog/1)
    |> Enum.reduce(%{}, &kinship/2)
    |> Enum.find(fn {_k, v} -> v == nil end)
    |> elem(0)
  end

  defp parse_prog(line) do
    # Return {prog name, prog weight, children (list)}
    {prog, children} =
      case String.split(line, "->") do
        [prog] ->
          {prog, []}
        [prog, children] ->
          {prog, children |> String.trim |> String.split(", ")}
      end
    name =
      prog
      |> String.split
      |> List.first
    {name, nil, children}
  end

  defp kinship({name, _, children}, acc) do
    case children do
      [] ->
        acc
      list ->
        new_children = Map.new(list, fn child -> {child, name} end)
        acc
        |> Map.merge(new_children)
        |> Map.update(name, nil, fn x ->
          if x != nil do
            x
          else
            nil
          end
        end)
    end
  end
end

File.stream!("day7.txt", [:utf8], :line)
|> Day7.solve
|> IO.puts
