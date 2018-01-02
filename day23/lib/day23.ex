defmodule Day23 do
  def solveA(filename) do
    instructions =
      filename
      |> parse
    rec_solve(instructions, %{}, 0, 0, tuple_size(instructions) - 1)
    |> elem(0)
  end

  def solveB(filename) do
    # Looking at the instructions we can see that h will be incremented when f = 0,
    # and f = 0 when b = d.e, and b will be incremented until it reaches c.
    # Since d and e starts both at 2 and get incremented by 1, the only times b will not be
    # equal to d.e is when b is a prime number.
    # So the number of incrementations for h is the number of times b is not a prime number,
    # start at the initial value of b, stopping when b reaches c, and incrementing b by the
    # given instructions.
    all_instructions =
      filename
      |> parse
      |> Tuple.to_list

    init_instructions =
      all_instructions
      |> Enum.take(8)
      |> List.to_tuple

    [{_, _, _, _, neg_increment}, _] =
      all_instructions
      |> Enum.drop(30)
    increment = - neg_increment

    {_, %{"b" => start, "c" => stop}} =
      init_instructions
      |> rec_solve(%{"a" => 1}, 0, 0, tuple_size(init_instructions) - 1)

    last =
      (stop - start) / increment
      |> round

    (for n <- 0..last, do: start + n * increment)
    |> Enum.reject(&is_prime/1)
    |> length
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
    {count, registers}
  end
  def rec_solve(instructions, registers, pos, count, max) do
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

  def is_prime(n) when n < 4 and n > 0, do: true
  def is_prime(n) do
    top = :math.sqrt(n) |> round
    2 .. top
    |> Enum.all?(fn i -> rem(n, i) != 0 end)
  end
end
