defmodule Day9 do

  def solve(chars) do
    chars
    |> rec_solve(0, false, false)
  end

  defp rec_solve(chars, garbage_count, into_garbage?, skip?) do
    if Enum.empty? chars do
      garbage_count
    else
      [head | tail ] = chars
      IO.puts "h: #{head}, garbage_count: #{garbage_count}, into garbage?: #{into_garbage?}, skip? #{skip?}"
      cond do
        skip? ->
          rec_solve(tail, garbage_count, into_garbage?, false)
        into_garbage? and head == ">" ->
          rec_solve(tail, garbage_count, false, skip?)
        into_garbage? and head == "!" ->
          rec_solve(tail, garbage_count, into_garbage?, true)
        into_garbage? ->
          rec_solve(tail, garbage_count + 1, into_garbage?, skip?)
        true ->
          case head do
            "!" ->
              rec_solve(tail, garbage_count, into_garbage?, true)
            "<" ->
              rec_solve(tail, garbage_count, true, skip?)
            _ ->
              rec_solve(tail, garbage_count, into_garbage?, skip?)
          end
      end
    end
  end
end

File.stream!("day9.txt", [:utf8], 1)
|> Enum.drop(-1)  # remove last \n
|> Day9.solve
|> IO.puts
