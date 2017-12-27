defmodule Day20Naive do
  @regex ~r/p=<(-?\d+),(-?\d+),(-?\d+)>, v=<(-?\d+),(-?\d+),(-?\d+)>, a=<(-?\d+),(-?\d+),(-?\d+)>/
  def solveA(filename) do
    particules =
      filename
      |> File.stream!([:utf8], :line)
      |> Enum.map(&parse_line/1)

    # We will consider 1 million iteration to be "in the long term"
    jump_time(particules, 1_000_001)
    |> nearest_zero
  end

  def parse_line(line) do
    [_ | values] = Regex.run(@regex, line)
    values
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple
  end

  def acceleration_factor(1), do: 1
  def acceleration_factor(t) do
    t + acceleration_factor(t - 1)
  end

  def jump_time(particules, t) do
    accel = acceleration_factor(t)

    formula =
      fn {px, py, pz, vx, vy, vz, ax, ay, az} ->
        {px + t * vx + accel * ax,
         py + t * vy + accel * ay,
         pz + t * vz + accel * az}
      end

    particules
    |> Enum.map(formula)
  end

  def nearest_zero(particules) do
    {sx, sy, sz} = Enum.at(particules, 0)
    particules
    |> Enum.reduce({0, 0, {sx, sy, sz}}, fn p, {idx, min, {cx, cy, cz}} ->
      {px, py, pz} = p
      if closer {px, py, pz}, {cx, cy, cz} do
        {idx + 1, idx, {px, py, pz}}
      else
        {idx + 1, min, {cx, cy, cz}}
      end
    end)
  end

  def closer({ax, ay, az}, {bx, by, bz}) do
    (abs(ax) + abs(ay) + abs(az)) < (abs(bx) + abs(by) + abs(bz))
  end
end
