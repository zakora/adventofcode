defmodule Day9 do

  def solve(chars) do
    chars
    |> rec_solve(0, 0, false, false)
  end

  defp rec_solve(chars, score, level, into_garbage?, skip?) do
    if Enum.empty? chars do
      score
    else
      [head | tail ] = chars
      IO.puts "h: #{head}, score: #{score}, into garbage?: #{into_garbage?}, skip? #{skip?}"
      cond do
        skip? ->
          rec_solve(tail, score, level, into_garbage?, false)
        into_garbage? and head == ">" ->
          rec_solve(tail, score, level, false, skip?)
        into_garbage? and head == "!" ->
          rec_solve(tail, score, level, into_garbage?, true)
        into_garbage? ->
          rec_solve(tail, score, level, into_garbage?, skip?)
        true ->
          case head do
            "!" ->
              rec_solve(tail, score, level, into_garbage?, true)
            "<" ->
              rec_solve(tail, score, level, true, skip?)
            "{" ->
              rec_solve(tail, score, level + 1, into_garbage?, skip?)
            "}" ->
              rec_solve(tail, score + level, level - 1, into_garbage?, skip?)
            _ ->
              rec_solve(tail, score, level, into_garbage?, skip?)
          end
      end
    end
  end
end

File.stream!("day9.txt", [:utf8], 1)
|> Enum.drop(-1)  # remove last \n
|> Day9.solve
|> IO.puts
