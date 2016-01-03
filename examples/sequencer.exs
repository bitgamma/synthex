defmodule Sequencer do
  alias Synthex.Context
  alias Synthex.Output.SoxPlayer
  alias Synthex.Generator.Oscillator
  alias Synthex.Filter.Moog
  alias Synthex.Sequencer
  alias Synthex.ADSR

  use Synthex.Math

  @rate 44100

  @bpm 70
  @jingle_bells "|g4-e5-d5-c5-g4-|-g4-g4-e5-d5-c5-a4-|-a4-a4-f5-e5-d5-b4-|-f5-f5-e5-d5-e5-|g4-e5-d5-c5-g4-|-g4-g4-e5-d5-c5-a4-|-a4-a4-f5-e5-d5-b4-|-f5-g5-g5-g5-g5-a5-g5-f5-d5-c5-|e5-e5-e5-|-e5-e5-e5-|-e5-g5-c5-d5-e5-|-f5-f5-f5-f5-f5-|-e5-e5-e5-e5-|-d5-d5-e5-d5-g5|e5-e5-e5-|-e5-e5-e5-|-e5-g5-c5-d5-e5-|-f5-f5-f5-f5-f5-|-e5-e5-e5-e5-|-g5-f5-e5-d5-c5--|"
  @happy_birthday "|--a4--a4--b4--a4--d5--C5---a4--a4--b4--a4-e5--d5----a4--a4-a5--F5--d5--C5---b4--g5-g5--F5--d5--e5--d5--|"
  @v_lesu_rodilas_elochka "|--c4-a4-a4-g4-a4-f4-c4-c4-c4-a4-a4-A4-g4-c5>>---c5-d4-d4-b4-b4-a4-g4-f4-c4-a4-a4-g4-a4-f4>>---e4-d4-d4-b4-b4-a4-g4-f4-c4-a4-a4-g4-a4-f4>>---|"
  def run() do
    {:ok, writer} = SoxPlayer.open(rate: @rate, channels: 1)
    sequencer = Sequencer.from_simple_string(@v_lesu_rodilas_elochka, Sequencer.bpm_to_duration(@bpm, 4))
    total_duration = Sequencer.sequence_duration(sequencer)

    context =
      %Context{output: writer, rate: @rate}
      |> Context.put_element(:main, :osc1, %Oscillator{algorithm: :pulse})
      |> Context.put_element(:main, :osc1_1, %Oscillator{algorithm: :sawtooth})
      |> Context.put_element(:main, :osc2, %Oscillator{algorithm: :pulse})
      |> Context.put_element(:main, :osc2_1, %Oscillator{algorithm: :sawtooth})
      |> Context.put_element(:main, :lfo, %Oscillator{algorithm: :triangle, frequency: 4})
      |> Context.put_element(:main, :adsr, ADSR.adsr(@rate, 1.0, 0.4, 0.000001, 0.4, 10, 10))
      |> Context.put_element(:main, :filter, %Moog{cutoff: 0.50, resonance: 1.1})
      |> Context.put_element(:main, :sequencer, sequencer)

    Synthex.synthesize(context, total_duration, fn (ctx) ->
      {ctx, {freq, amp}} = Context.get_sample(ctx, :main, :sequencer)
      {ctx, lfo} = Context.get_sample(ctx, :main, :lfo)
      {ctx, osc1} = Context.get_sample(ctx, :main, :osc1, %{frequency: freq, center: @pi - (lfo * @pi/1.1)})
      {ctx, osc1_1} = Context.get_sample(ctx, :main, :osc1_1, %{frequency: freq + (lfo * freq * 0.05)})
      {ctx, osc2} = Context.get_sample(ctx, :main, :osc2, %{frequency: (freq + 3.5), center: @pi - (lfo * @pi/1.1)})
      {ctx, osc2_1} = Context.get_sample(ctx, :main, :osc2_1, %{frequency: (freq + 3.5) + (lfo * freq * 0.05)})
      {ctx, adsr} = Context.get_sample(ctx, :main, :adsr, %{gate: ADSR.amplification_to_gate(amp)})
      mixed_sample = ((osc1 * 0.25) + (osc1_1 * 0.25) + (osc2 * 0.25) + (osc2_1 * 0.25)) * adsr
      Context.get_sample(ctx, :main, :filter, %{sample: mixed_sample})
    end)
    SoxPlayer.close(writer)
  end
end

Sequencer.run()