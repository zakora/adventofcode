defmodule Day17 do
  # size = iter + 1

  def solveA(input) do
    rec_solveA([0], 0, 0, 2017, input)
  end

  def solveB(input) do
    rec_solveB(nil, 0, 0, 50000000, input)
  end

  def rec_solveB(after_zero, _idx, iter, max_iter, _steps) when iter == max_iter do
    after_zero
  end
  def rec_solveB(after_zero, idx, iter, max_iter, steps) do
    pos = rem(idx + steps, iter + 1)
    after_zero =
      if pos == 0 do
        iter + 1
      else
        after_zero
      end
    idx = pos + 1
    rec_solveB(after_zero, idx, iter + 1, max_iter, steps)
  end

  def rec_solveA(cbuffer, idx, iter, max_iter, _steps) when iter == max_iter do
    Enum.at cbuffer, rem(idx + 1, iter + 1)
  end
  def rec_solveA(cbuffer, idx, iter, max_iter, steps) do
    pos = rem(idx + steps, iter + 1)
    cbuffer = List.insert_at cbuffer, pos + 1, iter + 1
    idx = pos + 1
    rec_solveA(cbuffer, idx, iter + 1, max_iter, steps)
  end
end
