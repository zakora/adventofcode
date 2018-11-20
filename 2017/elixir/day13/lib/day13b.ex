defmodule Day13B do

  def solve(filename) do
    {_positions, ranges, _max_depth} = Day13.get_init_state(filename)
    Stream.iterate(0, &(1 + &1))
    |> Enum.find(fn d -> not bad_delay(d, ranges) end)
  end

  def bad_delay(delay, ranges) do
    # Return true if the given delay leads to getting caught by a scanner
    Enum.any?(ranges, fn {depth, range} ->
      rem((delay + depth), (2 * (range - 1))) == 0
    end)
  end

end
