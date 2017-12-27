defmodule Day15 do
  def solveA(genA, genB) do
    rec_solveA(40000000, genA, genB, 0)
  end

  def solveB(startA, startB) do
    rec_solveB(5000000, startA, startB, 0)
  end

  def solveB_alt(startA, startB) do
    # slighty slower than solveB/2
    streamA = Stream.iterate(startA, fn x -> nextval(x, 16807, 4) end)
    streamB = Stream.iterate(startB, fn x -> nextval(x, 48271, 8) end)
    Stream.zip(streamA, streamB)
    |> Stream.drop(1)  # remove the first value from Stream.iterate
    |> Stream.take(5000000)
    |> Stream.filter(fn ({a, b}) -> to_bin_part(a) == to_bin_part(b) end)
    |> Enum.count
  end

  def rec_solveB(remaining, genA, genB, count) do
    factorA = 16807
    factorB = 48271
    if remaining == 0 do
      count
    else
      nextA = nextval(genA, factorA, 4)
      nextB = nextval(genB, factorB, 8)

      binA = to_bin_part(nextA)
      binB = to_bin_part(nextB)
      count =
        if binA == binB do
          count + 1
        else
          count
        end

      rec_solveB(remaining - 1, nextA, nextB, count)
    end
  end

  def rec_solveA(remaining, genA, genB, count) do
    factorA = 16807
    factorB = 48271
    if remaining == 0 do
      count
    else
      nextA = genval(genA, factorA)
      nextB = genval(genB, factorB)

      binA = to_bin_part(nextA)
      binB = to_bin_part(nextB)
      count =
        if binA == binB do
          count + 1
        else
          count
        end

      rec_solveA(remaining - 1, nextA, nextB, count)
    end
  end

  def nextval(x, factor, modulo) do
    next = genval(x, factor)
    if rem(next, modulo) == 0 do
      next
    else
      nextval(next, factor, modulo)
    end
  end

  def genval(prev, factor) do
    rem(prev * factor, 2147483647)
  end

  def to_bin_part(int) do
    int
    |> Integer.to_string(2)
    |> String.slice(-16..-1)
  end
end
