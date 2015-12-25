defmodule Sequencer do
  alias Synthex.Context
  alias Synthex.Output.SoxPlayer
  alias Synthex.Generator.Oscillator
  alias Synthex.Filter.Biquad
  alias Synthex.Sequencer

  use Synthex.Math

  @rate 44100

  @note_duration 0.15
  @jingle_bells "|g4-e5-d5-c5-g4-|-g4-g4-e5-d5-c5-a4-|-a4-a4-f5-e5-d5-b4-|-f5-f5-e5-d5-e5-|g4-e5-d5-c5-g4-|-g4-g4-e5-d5-c5-a4-|-a4-a4-f5-e5-d5-b4-|-f5-g5-g5-g5-g5-a5-g5-f5-d5-c5-|e5-e5-e5-|-e5-e5-e5-|-e5-g5-c5-d5-e5-|-f5-f5-f5-f5-f5-|-e5-e5-e5-e5-|-d5-d5-e5-d5-g5|e5-e5-e5-|-e5-e5-e5-|-e5-g5-c5-d5-e5-|-f5-f5-f5-f5-f5-|-e5-e5-e5-e5-|-g5-f5-e5-d5-c5|"

  def run() do
    {:ok, writer} = SoxPlayer.open(rate: @rate, channels: 1)
    sequencer = Sequencer.from_simple_string(@jingle_bells, @note_duration)
    total_duration = Sequencer.sequence_duration(sequencer)

    context =
      %Context{output: writer, rate: @rate}
      |> Context.put_element(:main, :osc1, %Oscillator{algorithm: :square})
      |> Context.put_element(:main, :filter, Biquad.lowpass(@rate, 880 * 2, 0.1))
      |> Context.put_element(:main, :sequencer, sequencer)

    Synthex.synthesize(context, total_duration, fn (ctx) ->
      {ctx, {freq, amp}} = Context.get_sample(ctx, :main, :sequencer)
      {ctx, osc1} = Context.get_sample(ctx, :main, :osc1, %{frequency: freq})
      Context.get_sample(ctx, :main, :filter, %{sample: osc1 * amp})
    end)

    SoxPlayer.close(writer)
  end
end

Sequencer.run()