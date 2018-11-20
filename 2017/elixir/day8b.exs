defmodule Day8 do

  def solve(lines) do
    lines
    |> Enum.reduce({0, %{}}, &parse/2)  # it is safe put 0 as a default max because we know the max is at least 4647 from the previous part
    |> elem(0)
  end

  defp parse(line, acc) do
    [inc_reg, func, inc_value, _, test_reg, operator, test_value] = String.split(line)
    {current_max, map} = acc

    inc_value = String.to_integer inc_value
    test_value = String.to_integer test_value
    test_reg_value = Map.get(map, test_reg, 0)

    if test(test_reg_value, operator, test_value) do
      inc_value =
        case func do
          "inc" ->
            Map.get(map, inc_reg, 0) + inc_value
          "dec" ->
            Map.get(map, inc_reg, 0) - inc_value
        end
      current_max = max(current_max, inc_value)
      map = Map.put(map, inc_reg, inc_value)
      {current_max, map}
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
