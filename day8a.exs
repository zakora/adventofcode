defmodule Day8 do

  def solve(lines) do
    lines
    |> Enum.reduce(%{}, &parse/2)
    |> Map.values
    |> Enum.max
  end

  defp parse(line, acc) do
    [inc_reg, func, inc_value, _, test_reg, operator, test_value] = String.split(line)

    inc_value = String.to_integer inc_value
    test_value = String.to_integer test_value
    test_reg_value = Map.get(acc, test_reg, 0)

    if test(test_reg_value, operator, test_value) do
      # do the instruction
      case func do
        "inc" ->
          Map.update(acc, inc_reg, inc_value, fn x -> x + inc_value end)
        "dec" ->
          Map.update(acc, inc_reg, -inc_value, fn x -> x - inc_value end)
      end
    else
      acc
    end
  end

  defp test(a, fun, b) do
    case fun do
      "<" ->
        a < b
      ">" ->
        a > b
      ">=" ->
        a >= b
      "<=" ->
        a <= b
      "!=" ->
        a != b
      "==" ->
        a == b
    end
  end

end

File.stream!("day8.txt", [:utf8], :line)
|> Day8.solve
|> IO.puts
