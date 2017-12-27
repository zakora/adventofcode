defmodule Day23 do
  def solveA(filename) do
    instructions =
      filename
      |> parse
    rec_solve(instructions, %{}, 0, 0, tuple_size(instructions) - 1)
    |> elem(0)
  end

  def solveB(filename) do
    instructions =
      filename
      |> parse
    rec_solve(instructions, %{"a" => 1}, 0, 0, tuple_size(instructions) - 1)
    |> elem(1)
  end

  def parse(filename) do
    filename
    |> File.stream!([:utf8], :line)
    |> Enum.map(&parse_line/1)
    |> List.to_tuple
  end

  def parse_line(line) do
    [instruction, x, y] =
      line
      |> String.trim
      |> String.split(" ")
    {typex, x} = try_reg_val x
    {typey, y} = try_reg_val y
    {instruction, typex, x, typey, y}
  end

  def try_reg_val(x) do
    try do
      {:val, String.to_integer x}
    rescue
      ArgumentError ->
        {:reg, x}
    end
  end

  def rec_solve(_instructions, registers, pos, count, max)
  when pos < 0 or pos > max do
    {count, Map.get(registers, "h")}
  end
  def rec_solve(instructions, registers, pos, count, max) do
    IO.puts "pos: #{pos}, val h: #{inspect registers}"
    {instr, typex, x, typey, y} = elem(instructions, pos)

    valx =
      case typex do
        :reg -> Map.get registers, x, 0
        :val -> x
      end
    valy =
      case typey do
        :reg -> Map.get registers, y, 0
        :val -> y
      end

    {registers, pos, count} =
      case instr do
        "set" ->
          registers = Map.put registers, x, valy
          {registers, pos + 1, count}
        "sub" ->
          registers = Map.put registers, x, valx - valy
          {registers, pos + 1, count}
        "mul" ->
          registers = Map.put registers, x, valx * valy
          {registers, pos + 1, count + 1}
        "jnz" ->
          pos =
            if valx != 0 do
              pos + valy
            else
              pos + 1
            end
          {registers, pos, count}
      end

    rec_solve(instructions, registers, pos, count, max)
  end
end
