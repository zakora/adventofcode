defmodule Day16 do

  def solveA(input, progs) do
    dance(parse_moves(input), parse_progs(progs))
    |> Enum.map(&Atom.to_string/1)
    |> Enum.join("")
  end

  def parse_moves(input) do
    input
    |> String.trim
    |> String.split(",")
    |> Enum.map(fn move ->
      case String.at move, 0 do
        "s" ->
          x =
            move
            |> String.slice(1..-1)
            |> String.to_integer
            {:s, x}

        "x" ->
          {_, exchange} = String.split_at move, 1
          [posa, posb] =
            String.split(exchange, "/")
            |> Enum.map(&String.to_integer/1)
          {:x, posa, posb}

        "p" ->
          {_, partners} = String.split_at move, 1
          [a, b] = String.split(partners, "/")
          {:p, a |> String.to_atom , b |> String.to_atom}
      end
    end)
  end

  def parse_progs(progs) do
    progs
    |> String.split("", trim: true)
    |> Enum.map(&String.to_atom/1)
  end

  def solveB(progs, input, n) do
    do_solveB(parse_progs(progs), parse_moves(input), MapSet.new, 0, n)
    |> Enum.map(&Atom.to_string/1)
    |> Enum.join("")
  end

  def do_solveB(progs, moves, seen, i, n) do
    cond do
      progs in seen ->
        IO.puts "progs already seen, rerun with n = #{rem(n, i)}"
      i == n ->
        progs
      True ->
        seen = MapSet.put(seen, progs)
        progs = dance(moves, progs)
        do_solveB(progs, moves, seen, i + 1, n)
    end
  end

  def dance([], progs), do: progs
  def dance(moves, progs) do
    [next_move | moves] = moves
    case next_move  do
      {:s, x} ->
        {first, last} = Enum.split progs, -x
        dance(moves, last ++ first)

      {:x, posa, posb} ->
        a = Enum.at progs, posa
        b = Enum.at progs, posb

        progs =
          progs
          |> List.replace_at(posa, b)
          |> List.replace_at(posb, a)

        dance(moves, progs)

      {:p, a, b} ->
        progs =
          progs
          |> Enum.map(fn c ->
            cond do
              c == a ->
                b
              c == b ->
                a
              True ->
                c
            end
          end)

        dance(moves, progs)
    end
  end
end
