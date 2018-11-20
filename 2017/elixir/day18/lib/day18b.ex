defmodule Day18B do
  def solve(filename) do
    instructions =
      File.stream!(filename, [:utf8], :line)
      |> Enum.map(&Day18.parse/1)
      |> List.to_tuple

    mediator = spawn fn ->
      receive do
        {p0, p1} ->
          send p0, p1
          send p1, p0
      end
    end

    p0 = spawn fn ->
      receive do
        pid ->
          run_prog(instructions, %{"p" => 0}, 0, :p0, pid, 0)
      end
    end

    p1 = spawn fn ->
      receive do
        pid ->
          run_prog(instructions, %{"p" => 1}, 0, :p1, pid, 0)
      end
    end

    send mediator, {p0, p1}
  end

  def run_prog(instructions, registers, position, me, friend, counter) do
    instr = elem(instructions, position)
    case instr do
      {:snd, reg} ->
        val = Map.get(registers, reg, 0)
        send friend, val
        counter =
          if me == :p1 do
            IO.puts "new counter for #{me} is #{counter + 1}"
            counter + 1
          else
            counter
          end
        run_prog(instructions, registers, position + 1, me, friend, counter)

      {:rcv, reg} ->
        val =
          receive do
            x -> x
          end
        registers = Map.put registers, reg, val
        run_prog(instructions, registers, position + 1, me, friend, counter)

      {:set, reg, :val, y} ->
        registers = Map.put registers, reg, y
        run_prog(instructions, registers, position + 1, me, friend, counter)
      {:set, xreg, :reg, yreg} ->
        val = Map.get registers, yreg, 0
        registers = Map.put registers, xreg, val
        run_prog(instructions, registers, position + 1, me, friend, counter)

      {:add, reg, :val, y} ->
        val = Map.get registers, reg, 0
        registers = Map.put registers, reg, val + y
        run_prog(instructions, registers, position + 1, me, friend, counter)
      {:add, xreg, :reg, yreg} ->
        yval = Map.get registers, yreg, 0
        xval = Map.get registers, xreg, 0
        registers = Map.put registers, xreg, xval + yval
        run_prog(instructions, registers, position + 1, me, friend, counter)

      {:mul, reg, :val, y} ->
        val = Map.get registers, reg, 0
        registers = Map.put registers, reg, val * y
        run_prog(instructions, registers, position + 1, me, friend, counter)
      {:mul, xreg, :reg, yreg} ->
        yval = Map.get registers, yreg, 0
        xval = Map.get registers, xreg, 0
        registers = Map.put registers, xreg, xval * yval
        run_prog(instructions, registers, position + 1, me, friend, counter)

      {:mod, reg, :val, y} ->
        val = Map.get registers, reg, 0
        registers = Map.put registers, reg, rem(val, y)
        run_prog(instructions, registers, position + 1, me, friend, counter)
      {:mod, xreg, :reg, yreg} ->
        yval = Map.get registers, yreg, 0
        xval = Map.get registers, xreg, 0
        registers = Map.put registers, xreg, rem(xval, yval)
        run_prog(instructions, registers, position + 1, me, friend, counter)

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
          run_prog(instructions, registers, position + yval, me, friend, counter)
        else
          run_prog(instructions, registers, position + 1, me, friend, counter)
        end
    end
  end
end
