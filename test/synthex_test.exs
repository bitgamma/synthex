defmodule SynthexTest do
  use ExUnit.Case
  doctest Synthex

  alias Synthex.Output.WavWriter
  alias Synthex.Output.WavHeader
  require Synthex.Math

  @duration 5

  @oscillator Synthex.Oscillator.Sine
  @oscillator_frequency 0.5

  @lfo Synthex.Oscillator.Triangle
  @lfo_frequency 18

  test "generate test file" do
    header = %WavHeader{channels: 1}
    {:ok, writer} = WavWriter.open("/Users/brain/tmp.wav", header)
    oscillator = @oscillator.init([frequency: @oscillator_frequency, rate: header.rate])
    lfo = @lfo.init([frequency: @lfo_frequency, rate: header.rate])

    Synthex.synthesize(writer, 0, fn (t) ->
      sample = @oscillator.get_sample(oscillator, t)
      lfo_sample = @lfo.get_sample(lfo, t)
      sample * lfo_sample
    end)

    Synthex.synthesize(writer, (header.rate * @duration), fn (t) ->
      lfo_sample = @lfo.get_sample(lfo, t)
      frequency = Synthex.Math.amplitude_to_rounded_frequency(lfo_sample, 110, 220)
      osc = @oscillator.init([frequency: frequency, rate: header.rate])
      @oscillator.get_sample(osc, t)
    end)

    WavWriter.close(writer)
  end
end
