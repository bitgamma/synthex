defmodule MorseDecoder do
  alias Synthex.Input.WavReader
  alias Synthex.Sequencer.Morse

  use Synthex.Math

  @window_size_ms Morse.wpm_to_dot_duration(120)

  def run(path) do
    reader = WavReader.open(path, false)
    sample_count = WavReader.get_sample_count(reader)
    window_size = trunc(@window_size_ms * reader.header.rate)
    window_count = div(sample_count, window_size)

    {_reader, morse_string} = Enum.reduce(1..window_count, {reader, ""}, fn(_x, {reader, acc}) ->
      {reader, sum} = sum_window(reader, window_size)
      {reader, acc <> evaluate_window(sum, window_size)}
    end)

    morse_parts = morse_string |> String.strip(?.) |> split_at_transition()
    period_len = morse_parts |> Enum.reduce(0, fn(x, acc) ->
      case x do
        <<?., _::binary>> -> acc
        x -> max(byte_size(x), acc)
      end
    end)
    period_len = period_len / 3

    Enum.reduce(morse_parts, "", fn(s, acc) ->
      s_len = byte_size(s)
      char_s = binary_part(s, 0, 1)

      decoded = cond do
        s_len < (period_len * 0.5) -> ""
        s_len <= (period_len * 2) -> char_s
        s_len <= (period_len * 5) -> String.duplicate(char_s, 3)
        true -> String.duplicate(char_s, 7)
      end

      acc <> decoded
    end)
    |> Morse.morse_to_text()
    |> IO.puts
  end

  defp sum_window(reader, window_size) do
    Enum.reduce(1..window_size, {reader, 0.0}, fn(_x, {reader, sum}) ->
      {reader, [sample | _]} = WavReader.get_sample(nil, reader)
      {reader, sum + abs(sample)}
    end)
  end

  defp evaluate_window(sum, window_size) when sum >= (window_size * 0.45), do: "="
  defp evaluate_window(_sum, _window_size), do: "."

  defp split_at_transition(string) do
    {_, strings} = Enum.reduce(to_char_list(string), {nil, []}, fn(c, {prev, list}) ->
      if prev == c do
        [h | rest] = list
        {c, [h <> <<c>> | rest]}
      else
        {c, [<<c>> | list]}
      end
    end)

    Enum.reverse(strings)
  end
end

MorseDecoder.run(hd(System.argv))