defmodule Day4 do
  def valid?(line) do
    line
    |> String.split
    |> duplicate_words?(false)
  end

  @doc """
  Check if there is any duplicate in the enumerable `words`.

  Returns 0 if there are duplicate words, 1 if there is no duplicate.
  """
  defp duplicate_words?(words, acc) do
    cond do
      acc == true ->
        0
      Enum.empty? words ->
        1
      true ->
        [head | tail ] = words
        duplicate_words?(tail, Enum.member?(tail, head))
    end
  end
end

File.stream!("day4.txt", [:utf8], :line)
|> Enum.map(&Day4.valid?/1)
|> Enum.sum
|> IO.puts
