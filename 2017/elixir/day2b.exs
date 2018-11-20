defmodule Day2 do
  def line_value(line, acc) do
    line
    |> String.split
    |> Enum.map(&String.to_integer/1)
    |> dividibles()
    |> Kernel.+(acc)
  end

  defp dividibles(numbers) do
    [head | tail] = numbers
    case find_div(head, tail) do
      {:ok, res} ->
        res
      _ ->
        dividibles(tail)
    end
  end

  defp find_div(x, xs) do
    res = xs
          |> Enum.map(fn(y) -> divpair(x, y) end)
          |> Enum.sum
    if res == 0 do
      {:err, res}
    else
      {:ok, res}
    end
  end

  defp divpair(a, b) do
    cond do
      a == b ->
        0
      a/b == div(a, b) ->
        div(a, b)
      b/a == div(b, a) ->
        div(b, a)
      true ->
        0
    end
  end
end

Enum.reduce(File.stream!("day2.txt", [:utf8], :line), 0, &Day2.line_value/2)
|> IO.puts
