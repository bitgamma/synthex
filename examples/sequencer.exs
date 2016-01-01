defmodule Sequencer do
  alias Synthex.Context
  alias Synthex.Output.SoxPlayer
  alias Synthex.Generator.Oscillator
  alias Synthex.Filter.Biquad
  alias Synthex.Sequencer
  alias Synthex.ADSR

  use Synthex.Math

  @rate 44100

  @bpm 90
  @jingle_bells "|g4-e5-d5-c5-g4-|-g4-g4-e5-d5-c5-a4-|-a4-a4-f5-e5-d5-b4-|-f5-f5-e5-d5-e5-|g4-e5-d5-c5-g4-|-g4-g4-e5-d5-c5-a4-|-a4-a4-f5-e5-d5-b4-|-f5-g5-g5-g5-g5-a5-g5-f5-d5-c5-|e5-e5-e5-|-e5-e5-e5-|-e5-g5-c5-d5-e5-|-f5-f5-f5-f5-f5-|-e5-e5-e5-e5-|-d5-d5-e5-d5-g5|e5-e5-e5-|-e5-e5-e5-|-e5-g5-c5-d5-e5-|-f5-f5-f5-f5-f5-|-e5-e5-e5-e5-|-g5-f5-e5-d5-c5--|"
  @happy_birthday "|--a4--a4--b4--a4--d5--C5---a4--a4--b4--a4-e5--d5----a4--a4-a5--F5--d5--C5---b4--g5-g5--F5--d5--e5--d5--|"
  @v_lesu_rodilas_elochka "|--c4-a4-a4-g4-a4-f4-c4-c4-c4-a4-a4-A4-g4-c5>>---c5-d4-d4-b4-b4-a4-g4-f4-c4-a4-a4-g4-a4-f4>>---e4-d4-d4-b4-b4-a4-g4-f4-c4-a4-a4-g4-a4-f4>>---|"
  def run() do
    {:ok, writer} = SoxPlayer.open(rate: @rate, channels: 1)
    sequencer = Sequencer.from_simple_string(@v_lesu_rodilas_elochka, Sequencer.bpm_to_duration(@bpm, 4))
    total_duration = Sequencer.sequence_duration(sequencer)

    context =
      %Context{output: writer, rate: @rate}
      |> Context.put_element(:main, :osc1, %Oscillator{algorithm: :sawtooth})
      |> Context.put_element(:main, :adsr, ADSR.adsr(@rate, 0.8, 0.1, 0.2, 1))
      |> Context.put_element(:main, :filter, Biquad.lowpass(@rate, 1760, 0.3))
      |> Context.put_element(:main, :sequencer, sequencer)

    Synthex.synthesize(context, total_duration, fn (ctx) ->
      {ctx, {freq, amp}} = Context.get_sample(ctx, :main, :sequencer)
      {ctx, osc1} = Context.get_sample(ctx, :main, :osc1, %{frequency: freq})
      {ctx, adsr} = Context.get_sample(ctx, :main, :adsr, %{gate: ADSR.amplification_to_gate(amp)})

      Context.get_sample(ctx, :main, :filter, %{sample: osc1 * adsr})
    end)

    SoxPlayer.close(writer)
  end
end

Sequencer.run()