defmodule Day20 do

  @regex_all ~r/p=<(-?\d+),(-?\d+),(-?\d+)>, v=<(-?\d+),(-?\d+),(-?\d+)>, a=<(-?\d+),(-?\d+),(-?\d+)>/
  @regex_accelerations ~r/p=<-?\d+,-?\d+,-?\d+>, v=<-?\d+,-?\d+,-?\d+>, a=<(-?\d+),(-?\d+),(-?\d+)>/

  def solveA(filename) do
    # Position at time t for a particule is:
    # Pt = P0 + x * V0 + y * A0
    # x is the velocity factor, x(t) = t
    # y is the acceleration factor, y(t) = t + y(t - 1) and y(1) = 1
    # so in the long term x < y
    # The position at t for a particule is thus governed by its initial acceleration.
    # We must find the particule with the lowest acceleration.
    accels =
      filename
      |> File.stream!([:utf8], :line)
      |> Enum.map(fn l -> parse_line(l, @regex_accelerations) end)

    min_accel =
      accels
      |> Enum.min_by(fn {ax, ay, az} -> abs(ax) + abs(ay) + abs(az) end)

    accels
    |> Enum.find_index(fn a -> a == min_accel end)
  end

  def solveB(filename) do
    particules =
      filename
      |> File.stream!([:utf8], :line)
      |> Enum.map(fn l -> parse_line(l, @regex_all) end)

    run(particules, false)
  end

  def parse_line(line, regex) do
    regex
    |> Regex.run(line, capture: :all_but_first)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple
  end
  def run(particules, true) do
    # once all particules are diverging
    length particules
  end
  def run(particules, false) do
    IO.puts :stderr, length(particules)
    a =
      particules
      |> Enum.map(&Tuple.to_list/1)
      |> Enum.map(fn [px, py, pz | _] -> {px, py, pz} end)
    if a != Enum.uniq a do
      IO.puts :stderr, "some collisions"
    end
    # remove collided particules
    current = remove_collisions(particules, MapSet.new, [])

    # compute next step
    next = step(current)
    run(next, all_diverging?(true, current, next))
  end

  def remove_collisions([], _collisions, acc), do: acc
  def remove_collisions(particules, collisions, acc) do
    positions =
      particules
      |> Enum.map(&to_pos/1)

    [pos | tail] = positions
    [p | particules] = particules

    {acc, collisions} =
      if MapSet.member?(collisions, pos) or pos in tail do
        {acc, MapSet.put(collisions, pos)}
      else
        {[ p | acc ], collisions}
      end
    remove_collisions(particules, collisions, acc)
  end

  def step(particules) do
    particules
    |> Enum.map(fn {px, py, pz, vx, vy, vz, ax, ay, az} ->
      {px + vx + ax,
       py + vy + ay,
       pz + vz + az,
       vx + ax,
       vy + ay,
       vz + az,
       ax,
       ay,
       az}
    end)
  end

  def all_diverging?(res, [], []), do: res
  def all_diverging?(false, _prev, _current), do: false
  def all_diverging?(true, prev, current) do
    [pa_prev | tail_prev] = prev
    [pa_current | tail_current] = current

    diverges_one_many?(pa_prev, pa_current, tail_prev, tail_current)
    |> all_diverging?(tail_prev, tail_current)
  end

  def diverges_one_many?(pa_prev, pa_current, tail_prev, tail_current) do
    Enum.zip(tail_prev, tail_current)
    |> Enum.any?(fn {pb_prev, pb_current} ->
      diverges_one_one? pa_prev, pa_current, pb_prev, pb_current
    end)
  end

  def diverges_one_one?(pa_prev, pa_current, pb_prev, pb_current) do
    {pax, pay, paz} = to_pos pa_prev
    {pbx, pby, pbz} = to_pos pb_prev
    dist_prev = abs(pax - pbx) + abs(pay - pby) + abs(paz - pbz)

    {pax, pay, paz} = to_pos pa_current
    {pbx, pby, pbz} = to_pos pb_current
    dist_next = abs(pax - pbx) + abs(pay - pby) + abs(paz - pbz)

    dist_prev < dist_next
  end

  def print(particules) do
    particules
    |> Enum.map(&to_pos/1)
    |> Enum.reduce("", fn {px, py, _}, acc ->
      acc <> " " <> Integer.to_string(px) <> " " <> Integer.to_string(py)
    end)
    |> IO.puts
  end

  def to_pos({px, py, pz, _, _, _, _, _, _}) do
    {px, py, pz}
  end
end
