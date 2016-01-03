defmodule Synthex.Sequencer.Morse do
  alias Synthex.Sequencer

  def from_text(text, dot_duration \\ 0.048, freq \\ 880.0) do
    morse_string = text_to_morse(text)
    from_morse(morse_string, dot_duration, freq)
  end

  def from_morse(morse_string, dot_duration, freq) do
    sequence =
      morse_string
      |> to_char_list()
      |> Enum.reduce([], fn(c, acc) -> [morse_char_to_freq(c, freq) | acc] end)
      |> Enum.reverse()

    %Sequencer{sequence: sequence, note_duration: dot_duration}
  end

  def wpm_to_dot_duration(wpm), do: 1.2 / wpm

  @text_to_morse_map %{
    ?A => "=.===",
    ?B => "===.=.=.=",
    ?C => "===.=.===.=",
    ?D => "===.=.=",
    ?E => "=",
    ?F => "=.=.===.=",
    ?G => "===.===.=",
    ?H => "=.=.=.=",
    ?I => "=.=",
    ?J => "=.===.===.===",
    ?K => "===.=.===",
    ?L => "=.===.=.=",
    ?M => "===.===",
    ?N => "===.=",
    ?O => "===.===.===",
    ?P => "=.===.===.=",
    ?Q => "===.===.=.===",
    ?R => "=.===.=",
    ?S => "=.=.=",
    ?T => "===",
    ?U => "=.=.===",
    ?V => "=.=.=.===",
    ?W => "=.===.===",
    ?X => "===.=.=.===",
    ?Y => "===.=.===.===",
    ?Z => "===.===.=.=",
    ?1 => "=.===.===.===.===",
    ?2 => "=.=.===.===.===",
    ?3 => "=.=.=.===.===",
    ?4 => "=.=.=.=.===",
    ?5 => "=.=.=.=.=",
    ?6 => "===.=.=.=.=",
    ?7 => "===.===.=.=.=",
    ?8 => "===.===.===.=.=",
    ?9 => "===.===.===.===.=",
    ?0 => "===.===.===.===.===",
    ?\s => "."
  }

  @morse_to_text_map Enum.map(@text_to_morse_map, fn({k, v}) -> {v, k} end) |> Enum.into(%{}) |> Map.put("+", ?\s)

  def text_to_morse(text) do
    text
    |> String.upcase
    |> String.replace(~r/[^A-Z0-9]+/, " ")
    |> to_char_list()
    |> Enum.reduce("", fn(c, acc) -> acc <> "..." <> @text_to_morse_map[c] end)
  end

  def morse_to_text(morse_string) do
    morse_string
    |> String.replace(".......", "...+...")
    |> String.split(~r/[\.]{3,7}/, trim: true)
    |> Enum.map(fn(s) -> replace_nil(@morse_to_text_map[s]) end)
    |> to_string()
    |> String.strip()
  end

  defp morse_char_to_freq(?=, freq), do: {freq, 1.0}
  defp morse_char_to_freq(?., freq), do: {freq, 0.0}

  defp replace_nil(nil), do: ??
  defp replace_nil(c), do: c

end