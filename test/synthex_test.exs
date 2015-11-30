defmodule SynthexTest do
  use ExUnit.Case
  doctest Synthex

  alias Synthex.Output.WavWriter
  alias Synthex.Output.WavHeader

  @duration 200

  @oscillator Synthex.Oscillator.Sine
  @oscillator_frequency 5

  @lfo Synthex.Oscillator.Sawtooth
  @lfo_frequency 2

  defp generate_frequency(min, max, magnitude) do
    ((magnitude + 1) * ((max - min)/2)) + min
  end

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
      osc = @oscillator.init([frequency: generate_frequency(170, 270, lfo_sample), rate: header.rate])
      @oscillator.get_sample(osc, t)
    end)

    WavWriter.close(writer)
  end
end
