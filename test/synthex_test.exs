defmodule SynthexTest do
  use ExUnit.Case
  doctest Synthex

  alias Synthex.Output.WavWriter
  alias Synthex.Output.WavHeader

  @duration 5

  @oscillator Synthex.Oscillator.Sawtooth
  @oscillator_frequency 220

  @lfo Synthex.Oscillator.Sine
  @lfo_weight 1.0
  @lfo_frequency 5

  test "generate test file" do
    header = %WavHeader{channels: 1}
    {:ok, writer} = WavWriter.open("/Users/brain/tmp.wav", header)
    oscillator = @oscillator.init([frequency: @oscillator_frequency, rate: header.rate])
    lfo = @lfo.init([frequency: @lfo_frequency, rate: header.rate])

    Synthex.synthesize(writer, (header.rate * @duration), fn (t) ->
      sample = @oscillator.get_sample(oscillator, t)
      lfo = @lfo.get_sample(lfo, t)
      sample * lfo * @lfo_weight
    end)

    Synthex.synthesize(writer, (header.rate * @duration), fn (t) ->
      @oscillator.get_sample(oscillator, t)
    end)

    WavWriter.close(writer)
  end
end
