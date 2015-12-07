defmodule Filter do
  alias Synthex.Context
  alias Synthex.Output.WavWriter
  alias Synthex.Output.WavHeader
  alias Synthex.Generator.Oscillator
  alias Synthex.Filter.Moog
  use Synthex.Math

  def run(duration) do
    header = %WavHeader{channels: 1}
    {:ok, writer} = WavWriter.open(System.user_home() <> "/filter.wav", header)
    context =
      %Context{output: writer, rate: header.rate}
      |> Context.put_element(:main, :osc1, %Oscillator{algorithm: :sine})
      |> Context.put_element(:main, :lfo, %Oscillator{algorithm: :triangle, frequency: 0.1})
      |> Context.put_element(:main, :filter, %Moog{cutoff: 0.07, resonance: 3.2})

    Synthex.synthesize(context, duration, fn (ctx) ->
      {ctx, lfo} = Context.get_sample(ctx, :main, :lfo)
      {ctx, osc1} = Context.get_sample(ctx, :main, :osc1, %{frequency: amplitude_to_frequency(lfo, 110, 1100)})
      Context.get_sample(ctx, :main, :filter, %{sample: osc1})
    end)

    WavWriter.close(writer)
  end
end

Filter.run(5)