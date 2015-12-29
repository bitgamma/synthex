defmodule Synthex.Sequencer do
  alias Synthex.Context
  alias Synthex.Sequencer

  defstruct [sequence: nil, note_duration: 0.15, loop: true, playing_sequence: nil, step: 0]

  @silence {0.000000001, 0.0, :idle}

  def get_sample(_ctx, state = %Sequencer{playing_sequence: [], loop: false}), do: {state, @silence}
  def get_sample(ctx, state = %Sequencer{sequence: sequence, playing_sequence: ps, loop: l}) when (ps == nil) or (ps == [] and l == true) do
    get_sample(ctx, %Sequencer{state | playing_sequence: sequence})
  end
  def get_sample(%Context{rate: rate}, state = %Sequencer{playing_sequence: [note | _] = sequence, note_duration: note_duration, step: step}) do
    step_delta = 1 / rate
    {new_sequence, new_step} = get_next_step(step + step_delta, note_duration, sequence)

    {%Sequencer{state | playing_sequence: new_sequence, step: new_step}, note}
  end

  defp get_next_step(step, note_duration, sequence) when step < note_duration, do: {sequence, step}
  defp get_next_step(step, note_duration, [_note | rest]), do: {rest, step - note_duration}

  def sequence_duration(%Sequencer{sequence: sequence, note_duration: note_duration}), do: length(sequence) * note_duration

  def bpm_to_duration(bpm, notes_per_beat), do: 60 / bpm / notes_per_beat

  defdelegate from_simple_string(string, note_duration), to: Synthex.Sequencer.SimpleStringFormat
end