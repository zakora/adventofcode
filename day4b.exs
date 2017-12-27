require Logger

defmodule Day4 do
  def valid?(line) do
    line
    |> String.split
    |> anagram_words?(false)
  end

  defp anagram_words?(words, acc) do
    # Check if any word of `words` is an anagram of another.
    # Returns 0 if there are anagrams, 1 if there is none.
    cond do
      acc == true ->
        0
      Enum.empty? words ->
        1
      true ->
        [head | tail ] = words
        anagram_words?(tail, Enum.any?(tail, fn (x) -> anagram?(x, head) end))
    end
  end

  defp anagram?(x, y) do
    # True if x is an anagram of y, False otherwise
    Enum.sort(String.split(x, "")) == Enum.sort(String.split(y, ""))
  end
end

File.stream!("day4.txt", [:utf8], :line)
|> Enum.map(&Day4.valid?/1)
|> Enum.sum
|> IO.puts
