defmodule SynthexTest do
  use ExUnit.Case
  doctest Synthex

  alias Synthex.Output.WavWriter
  alias Synthex.Output.WavHeader

  @duration 5

  @oscillator Synthex.Oscillator.Square
  @oscillator_amplitude 16767
  @oscillator_frequency 110

  @lfo Synthex.Oscillator.Sawtooth
  @lfo_amplitude 16000
  @lfo_frequency 2

  defp generate_sample(oscillator, t, amplitude) do
    round(@oscillator.get_sample(oscillator, t) * amplitude)
  end

  defp generate_frequency_offset(lfo, t) do
    round(@lfo.get_sample(lfo, t) * @lfo_amplitude)
  end

  test "generate test file" do
    header = %WavHeader{channels: 1}
    {:ok, writer} = WavWriter.open("/Users/brain/tmp.wav", header)
    oscillator = @oscillator.init([frequency: @oscillator_frequency, rate: header.rate])
    lfo = @lfo.init([frequency: @lfo_frequency, rate: header.rate])

    Enum.reduce(0..(header.rate * @duration), @oscillator_amplitude, fn (t, amplitude) ->
      WavWriter.write_samples(writer, generate_sample(oscillator, t, amplitude))
      off = generate_frequency_offset(lfo, t)
      @oscillator_amplitude + off
    end)
    WavWriter.close(writer)
  end
end
