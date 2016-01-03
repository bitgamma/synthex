defmodule MorseEx do
  alias Synthex.Context
  alias Synthex.Output.WavWriter
  alias Synthex.File.WavHeader
  alias Synthex.Generator.Oscillator
  alias Synthex.Sequencer
  alias Synthex.Sequencer.Morse
  alias Synthex.ADSR

  use Synthex.Math

  def run() do
    header = %WavHeader{channels: 1, format: :float, sample_size: 32}
    {:ok, writer} = WavWriter.open(System.user_home() <> "/morse.wav", header)

    sequencer = Morse.from_text("Hello world", Morse.wpm_to_dot_duration(15))
    duration = Sequencer.sequence_duration(sequencer)

    context =
      %Context{output: writer, rate: header.rate}
      |> Context.put_element(:main, :osc1, %Oscillator{algorithm: :sine})
      |> Context.put_element(:main, :adsr, ADSR.adsr(header.rate, 1.0, 0.01, 0.000001, 0.01, 10, 10))
      |> Context.put_element(:main, :sequencer, sequencer)

    Synthex.synthesize(context, duration, fn (ctx) ->
      {ctx, {freq, amp}} = Context.get_sample(ctx, :main, :sequencer)
      {ctx, osc1} = Context.get_sample(ctx, :main, :osc1, %{frequency: freq})
      {ctx, adsr} = Context.get_sample(ctx, :main, :adsr, %{gate: ADSR.amplification_to_gate(amp)})
      {ctx, osc1 * adsr}
    end)

    WavWriter.close(writer)
    :timer.sleep(100)
  end
end

MorseEx.run()