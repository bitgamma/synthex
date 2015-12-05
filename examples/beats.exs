defmodule Beats do
  alias Synthex.Context
  alias Synthex.Output.WavWriter
  alias Synthex.Output.WavHeader
  alias Synthex.Generator.Oscillator
  alias Synthex.Generator.Noise
  use Synthex.Math

  def run(duration) do
    header = %WavHeader{channels: 1}
    {:ok, writer} = WavWriter.open("/Users/brain/tmp.wav", header)
    context =
      %Context{output: writer, rate: header.rate}
      |> Context.put_element(:main, :osc1, %Oscillator{algorithm: :sawtooth, frequency: 1, sync_frequency: 2})
      |> Context.put_element(:main, :osc2, %Oscillator{algorithm: :pulse, frequency: 0.5, center: duty_cycle_to_radians(0.75)})
      |> Context.put_element(:main, :osc3, %Oscillator{algorithm: :triangle, frequency: 0.02})
      |> Context.put_element(:main, :noise, %Noise{type: :brown})

    Synthex.synthesize(context, duration, fn (ctx) ->
      {ctx, osc3} = Context.get_sample(ctx, :main, :osc3)

      {ctx, osc1} = Context.get_sample(ctx, :main, :osc1, %{frequency: amplitude_to_frequency(osc3, 0.8, 4), sync_frequency: amplitude_to_frequency(osc3, 1.6, 8)})
      {ctx, osc2} = Context.get_sample(ctx, :main, :osc2, %{frequency: amplitude_to_frequency(osc3, 0.4, 2)})
      {ctx, noise} = Context.get_sample(ctx, :main, :noise)

      {ctx, osc1 * noise * shift_by(osc2, 1)}
    end)
    WavWriter.close(writer)
  end
end

Beats.run(20)