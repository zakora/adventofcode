Enum.reduce(File.stream!("day2.txt", [:utf8], :line), 0, fn (line, acc) ->
  line
  |> String.split
  |> Enum.map(&String.to_integer/1)
  |> Enum.min_max
  |> (fn {min, max} -> acc + max - min end).()
end)
|> IO.puts
