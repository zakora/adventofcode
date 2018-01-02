defmodule Day25 do
  @start_state ~r/Begin in state ([A-Z])\./
  @nsteps ~r/Perform a diagnostic checksum after (\d+) steps\./
  @in_state ~r/In state ([A-Z])\:/
  @if_value ~r/If the current value is (0|1)\:/
  @write ~r/- Write the value (0|1)\./
  @move ~r/- Move one slot to the (left|right)\./
  @continue ~r/- Continue with state ([A-Z])\./

  def solveA(filename) do
    {start_state, nsteps, rules} = parse(filename)
    run 0, start_state, MapSet.new, nsteps, rules
  end

  def parse(filename) do
    [begin_line, steps_line, _ | lines] =
      filename
      |> File.stream!([:utf8], :line)
      |> Enum.map(&String.trim/1)

    start_state =
      regex_first(@start_state, begin_line)
      |> String.to_atom
    nsteps =
      regex_first(@nsteps, steps_line)
      |> String.to_integer

    rules = get_rules lines, nil, %{}

    {start_state, nsteps, rules}
  end

  def regex_first(regex, string) do
    [res | _] = Regex.run regex, string, capture: :all_but_first
    res
  end

  def to_value(x) do
    if x == "0", do: false, else: true
  end

  def get_rules([], _state, rules), do: rules
  def get_rules(lines, state, rules) do
    [line | tail] = lines
    cond do
      Regex.match? @in_state, line ->
        state =
          regex_first(@in_state, line)
          |> String.to_atom
        get_rules tail, state, rules

      Regex.match? @if_value, line ->
        cursor_value =
          regex_first(@if_value, line)
          |> to_value

        [write_line, move_line, continue_line | tail] = tail
        write =
          regex_first(@write, write_line)
          |> to_value
        move = regex_first @move, move_line
        idx_diff =
          case move do
            "left" -> -1
            "right" -> +1
          end
        continue =
          regex_first(@continue, continue_line)
          |> String.to_atom

        rules = Map.put rules, {state, cursor_value}, {write, idx_diff, continue}
        get_rules tail, state, rules

      true ->  # on empty lines
        get_rules tail, state, rules
    end
  end

  def run(_cursor, _state, tape, 0, _rules), do: MapSet.size tape
  def run(cursor, state, tape, steps, rules) do
    value = if MapSet.member?(tape, cursor), do: true, else: false
    {write, idx_diff, state} = Map.get rules, {state, value}
    tape =
      if write do
        MapSet.put tape, cursor
      else
        MapSet.delete tape, cursor
      end
    run(cursor + idx_diff, state, tape, steps - 1, rules)
  end
end
