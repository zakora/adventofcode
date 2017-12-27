defmodule Mu do
  def run do
    IO.puts "runngin @#{inspect self()}"

    mediator = spawn fn ->
      receive do
        {p0, p1} ->
          send p0, p1
          send p1, p0
      end
    end

    p0 = spawn fn ->
      receive do
        pid ->
        IO.puts "hello I'm #{inspect self()} and my friend is #{inspect pid}"
      end
    end

    p1 = spawn fn ->
      receive do
        pid ->
          IO.puts "hello I'm #{inspect self()} and my friend is #{inspect pid}"
      end
    end

    send mediator, {p0, p1}

  end

  def myprog do
    receive do
      pid ->
        IO.puts "hello I'm #{inspect self()} and my friend is #{inspect pid}"
    end
  end
end
