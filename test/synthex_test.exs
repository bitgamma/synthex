defmodule SynthexTest do
  use ExUnit.Case
  doctest Synthex

  alias Synthex.Output.WavWriter
  alias Synthex.Output.WavHeader

  @duration 5

  @oscillator Synthex.Oscillator.Square
  @oscillator_frequency 110

  @lfo Synthex.Oscillator.Sawtooth
  @lfo_weight 1.0
  @lfo_frequency 2

  test "generate test file" do
    header = %WavHeader{channels: 1}
    {:ok, writer} = WavWriter.open("/Users/brain/tmp.wav", header)
    oscillator = @oscillator.init([frequency: @oscillator_frequency, rate: header.rate])
    lfo = @lfo.init([frequency: @lfo_frequency, rate: header.rate])

    Enum.each(0..(header.rate * @duration), fn (t) ->
      sample = @oscillator.get_sample(oscillator, t)
      lfo = @lfo.get_sample(lfo, t)
      WavWriter.write_samples(writer, sample * lfo * @lfo_weight)
    end)
    WavWriter.close(writer)
  end
end
