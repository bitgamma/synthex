defmodule SynthexTest do
  use ExUnit.Case
  doctest Synthex

  alias Synthex.Context
  alias Synthex.Output.WavWriter
  alias Synthex.Output.WavHeader
  alias Synthex.Generator.Oscillator
  use Synthex.Math

  @duration 5

  test "generate test file" do
    header = %WavHeader{channels: 1}
    {:ok, writer} = WavWriter.open("/Users/brain/tmp.wav", header)
    context =
      %Context{output: writer, rate: header.rate}
      |> Context.put_element(:main, :osc1, %Oscillator{algorithm: :sine})
      |> Context.put_element(:main, :osc2, %Oscillator{algorithm: :triangle, frequency: 220})
      |> Context.put_element(:main, :lfo1, %Oscillator{algorithm: :sawtooth, frequency: 20, sync_frequency: 220})

    Synthex.synthesize(context, @duration, fn (ctx) ->
      {ctx, lfo1_sample} = Context.get_sample(ctx, :main, :lfo1)
      {ctx, osc1_sample} = Context.get_sample(ctx, :main, :osc1, %{frequency: amplitude_to_rounded_frequency(lfo1_sample, 110, 440)})
      {ctx, osc2_sample} = Context.get_sample(ctx, :main, :osc2)

      {ctx, clamp(osc1_sample + osc2_sample)}
    end)

    WavWriter.close(writer)
  end
end
