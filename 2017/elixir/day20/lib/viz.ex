defmodule Viz do
  @regex ~r/p=<(-?\d+),(-?\d+),(-?\d+)>, v=<(-?\d+),(-?\d+),(-?\d+)>, a=<(-?\d+),(-?\d+),(-?\d+)>/
  def run(filename, n) do
    particules =
      filename
      |> File.stream!([:utf8], :line)
      |> Enum.map(&parse_line/1)
    out(particules, n)
  end

  def parse_line(line) do
    Regex.run(@regex, line, capture: :all_but_first)
    |> Enum.map(&String.to_integer/1)
  end

  def out(_particules, 0), do: :ok
  def out(particules, n) do
    print(particules)

    particules =
      particules
      |> Enum.map(fn [px, py, pz, vx, vy, vz, ax, ay, az] ->
        [px + vx + ax,
         py + vy + ay,
         pz + vz + az,
         vx + ax,
         vy + ay,
         vz + az,
         ax,
         ay,
         az]
      end)

    out(particules, n - 1)
  end

  def print(particules) do
    particules
    |> Enum.reduce("", fn [px, py| _], acc ->
      acc <> " " <> Integer.to_string(px) <> " " <> Integer.to_string(py)
    end)
    |> IO.puts
  end
end
