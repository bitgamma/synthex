defmodule SynthexTest do
  use ExUnit.Case
  doctest Synthex

  alias Synthex.Context
  alias Synthex.Output.WavWriter
  alias Synthex.Output.WavHeader
  alias Synthex.Generator.Oscillator
  require Synthex.Math

  @duration 5

  @oscillator Synthex.Oscillator.Square
  @oscillator_frequency 0.5

  @mfo Synthex.Oscillator.Sine
  @mfo_frequency 100

  @lfo Synthex.Oscillator.Sawtooth
  @lfo_frequency 5

  test "generate test file" do
    header = %WavHeader{channels: 1}
    {:ok, writer} = WavWriter.open("/Users/brain/tmp.wav", header)
    context = %Context{output: writer, rate: header.rate}

    Synthex.synthesize(context, @duration, fn (ctx, t) ->
#     lfo = @lfo.init([frequency: @lfo_frequency, rate: header.rate])
#     lfo_sample = @lfo.get_sample(lfo, t)

#     mfo = @mfo.init([frequency: Synthex.Math.amplitude_to_rounded_frequency(lfo_sample, 110, 880), rate: header.rate])
#     mfo_sample = @mfo.get_sample(mfo, t)

#     osc = @oscillator.init([frequency: Synthex.Math.amplitude_to_rounded_frequency(mfo_sample, 100, 130), rate: header.rate])
#     osc_sample = @oscillator.get_sample(osc, t)
#     Synthex.Math.clamp(osc_sample + mfo_sample)
      left = %Oscillator{algorithm: :sawtooth, frequency: 220}
      {_, lsample} = Oscillator.generate_sample(ctx, left, t)

      #right = %Oscillator{algorithm: :triangle, frequency: 220, period: (header.rate / 220), offset: 0}
      #{_, rsample} = Oscillator.generate_sample(%{rate: 44100}, right, t)

      {ctx, Synthex.Math.clamp(lsample)}
    end)

    WavWriter.close(writer)
  end
end
