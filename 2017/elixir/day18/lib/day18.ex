defmodule Day18 do
  def solveA(filename) do
    instructions =
      File.stream!(filename, [:utf8], :line)
      |> Enum.map(&parse/1)
      |> List.to_tuple
    rec_solveA(instructions, %{}, 0, nil)
  end

  def parse(line) do
    case line |> String.trim |> String.split(" ") do
      [instr, reg] ->
        {instr |> String.to_atom, reg}
      ["jgz", x, y] ->
        {xtype, x} = parse_reg_val x
        {ytype, y} = parse_reg_val y
        {:jgz, xtype, x, ytype, y}
      [instr, reg, y] ->
        {type, y} = parse_reg_val y
        {instr |> String.to_atom, reg, type, y}
    end
  end

  def parse_reg_val(x) do
    try do
      {:val, String.to_integer x}
    rescue
      ArgumentError ->
        {:reg, x}
    end
  end

  def rec_solveA(instructions, registers, position, last_freq) do
    instr = elem(instructions, position)
    IO.puts "hello"
    case instr do
      {:snd, reg} ->
        freq = Map.get(registers, reg, 0)
        rec_solveA(instructions, registers, position + 1, freq)

      {:set, reg, :val, y} ->
        registers = Map.put registers, reg, y
        rec_solveA(instructions, registers, position + 1, last_freq)
      {:set, xreg, :reg, yreg} ->
        val = Map.get registers, yreg, 0
        registers = Map.put registers, xreg, val
        rec_solveA(instructions, registers, position + 1, last_freq)

      {:add, reg, :val, y} ->
        val = Map.get registers, reg, 0
        registers = Map.put registers, reg, val + y
        rec_solveA(instructions, registers, position + 1, last_freq)
      {:add, xreg, :reg, yreg} ->
        yval = Map.get registers, yreg, 0
        xval = Map.get registers, xreg, 0
        registers = Map.put registers, xreg, xval + yval
        rec_solveA(instructions, registers, position + 1, last_freq)

      {:mul, reg, :val, y} ->
        val = Map.get registers, reg, 0
        registers = Map.put registers, reg, val * y
        rec_solveA(instructions, registers, position + 1, last_freq)
      {:mul, xreg, :reg, yreg} ->
        yval = Map.get registers, yreg, 0
        xval = Map.get registers, xreg, 0
        registers = Map.put registers, xreg, xval * yval
        rec_solveA(instructions, registers, position + 1, last_freq)

      {:mod, reg, :val, y} ->
        val = Map.get registers, reg, 0
        registers = Map.put registers, reg, rem(val, y)
        rec_solveA(instructions, registers, position + 1, last_freq)
      {:mod, xreg, :reg, yreg} ->
        yval = Map.get registers, yreg, 0
        xval = Map.get registers, xreg, 0
        registers = Map.put registers, xreg, rem(xval, yval)
        rec_solveA(instructions, registers, position + 1, last_freq)

      {:rcv, reg} ->
        val = Map.get registers, reg, 0
        if val != 0 do
          last_freq
        else
          rec_solveA(instructions, registers, position + 1, last_freq)
        end

      {:jgz, xtype, x, ytype, y} ->
        xval =
          case xtype do
            :val -> x
            :reg -> Map.get registers, x, 0
          end
        yval =
          case ytype do
            :val -> y
            :reg -> Map.get registers, y, 0
          end
        if xval > 0 do
          rec_solveA(instructions, registers, position + yval, last_freq)
        else
          rec_solveA(instructions, registers, position + 1, last_freq)
        end
    end
  end
end
