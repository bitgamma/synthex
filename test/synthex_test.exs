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
      |> Context.put_element(:main, :osc1, %Oscillator{algorithm: :sine, frequency: 220})
      |> Context.put_element(:main, :osc2, %Oscillator{algorithm: :triangle, frequency: 220})
      |> Context.put_element(:main, :lfo1, %Oscillator{algorithm: :sawtooth, frequency: 20, sync_frequency: 220})

    Synthex.synthesize(context, @duration, fn (ctx, t) ->
      lfo1 = Context.get_element(ctx, :main, :lfo1)
      {_, lfo1_sample} = Oscillator.generate_sample(ctx, lfo1, t)

      osc1 = Context.get_element(ctx, :main, :osc1) |> Map.put(:frequency, amplitude_to_rounded_frequency(lfo1_sample, 180, 240))
      {_, osc1_sample} = Oscillator.generate_sample(ctx, osc1, t)

      osc2 = Context.get_element(ctx, :main, :osc2)
      {_, osc2_sample} = Oscillator.generate_sample(ctx, osc2, t)

      {ctx, clamp(osc1_sample + osc2_sample)}
    end)

    WavWriter.close(writer)
  end
end
