defmodule SynthexTest do
  use ExUnit.Case
  doctest Synthex

  alias Synthex.Output.WavWriter
  alias Synthex.Output.WavHeader
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
    lfo = @lfo.init([frequency: @lfo_frequency, rate: header.rate])

    Synthex.synthesize(writer, (header.rate * @duration), fn (t) ->
      lfo_sample = @lfo.get_sample(lfo, t)

      mfo = @mfo.init([frequency: Synthex.Math.amplitude_to_rounded_frequency(lfo_sample, 110, 880), rate: header.rate])
      mfo_sample = @mfo.get_sample(mfo, t)

      osc = @oscillator.init([frequency: Synthex.Math.amplitude_to_rounded_frequency(mfo_sample, 100, 130), rate: header.rate])
      osc_sample = @oscillator.get_sample(osc, t)
      Synthex.Math.clamp(osc_sample + mfo_sample)
    end)

    WavWriter.close(writer)
  end
end
