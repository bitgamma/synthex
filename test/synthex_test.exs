defmodule SynthexTest do
  use ExUnit.Case
  doctest Synthex

  alias Synthex.Context
  alias Synthex.Output.WavWriter
  alias Synthex.Output.WavHeader
  alias Synthex.Generator.Oscillator
  require Synthex.Math

  @duration 5

  test "generate test file" do
    header = %WavHeader{channels: 1}
    {:ok, writer} = WavWriter.open("/Users/brain/tmp.wav", header)
    context = %Context{output: writer, rate: header.rate}

    Synthex.synthesize(context, @duration, fn (ctx, t) ->
      left = %Oscillator{algorithm: :sawtooth, frequency: 220}
      {_, lsample} = Oscillator.generate_sample(ctx, left, t)
      {ctx, Synthex.Math.clamp(lsample)}
    end)

    WavWriter.close(writer)
  end
end
