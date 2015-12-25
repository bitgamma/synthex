defmodule Synthex.Sequencer do
  alias Synthex.Context
  alias Synthex.Sequencer

  defstruct [sequence: nil, note_duration: 0.15, step: 0]

  @silence {0.0000001, 0.0}

  def get_sample(_ctx, state = %Sequencer{sequence: []}), do: {state, @silence}
  def get_sample(%Context{rate: rate}, state = %Sequencer{sequence: [note | _] = sequence, note_duration: note_duration, step: step}) do
    step_delta = 1 / rate
    {new_sequence, new_step} = get_next_step(step + step_delta, note_duration, sequence)

    {%Sequencer{state | sequence: new_sequence, step: new_step}, note}
  end

  defp get_next_step(step, note_duration, sequence) when step < note_duration, do: {sequence, step}
  defp get_next_step(step, note_duration, [_note | rest]), do: {rest, step - note_duration}

  @notes %{
    "a5" => 880.000,
    "g5" => 783.991,
    "f5" => 698.456,
    "e5" => 659.255,
    "d5" => 587.330,
    "c5" => 523.251,
    "b4" => 493.883,
    "a4" => 440.000,
    "g4" => 391.995,
  }

  def sequence_duration(%Sequencer{sequence: sequence, note_duration: note_duration}), do: length(sequence) * note_duration

  def from_simple_string(string, note_duration) do
    sequence = string
    |> String.downcase
    |> String.replace("|", "")
    |> String.replace("-", "--")
    |> sequence_simple_string([])

    %Sequencer{sequence: sequence, note_duration: note_duration}
  end

  defp sequence_simple_string("", sequence), do: Enum.reverse(sequence)
  defp sequence_simple_string(song, sequence) do
    {note, rest} = String.split_at(song, 2)
    decoded_note = decode_note(note)
    sequence_simple_string(rest, [decoded_note | sequence])
  end

  defp decode_note("--"), do: @silence
  defp decode_note(note), do: {Map.fetch!(@notes, note), 1.0}
end