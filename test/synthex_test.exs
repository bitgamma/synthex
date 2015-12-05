defmodule SynthexTest do
  use ExUnit.Case
  doctest Synthex

  alias Synthex.Context
  alias Synthex.Output.WavWriter
  alias Synthex.Output.WavHeader
  alias Synthex.Generator.Oscillator
  alias Synthex.Generator.Noise
  use Synthex.Math

  @duration 5

  test "generate test file" do
    header = %WavHeader{channels: 1}
    {:ok, writer} = WavWriter.open("/Users/brain/tmp.wav", header)
    context =
      %Context{output: writer, rate: header.rate}
      |> Context.put_element(:main, :osc1, %Oscillator{algorithm: :sine, frequency: 0.1})
      |> Context.put_element(:main, :noise, %Noise{type: :pink})

    Synthex.synthesize(context, @duration, fn (ctx) ->
      {ctx, osc1} = Context.get_sample(ctx, :main, :osc1)
      {ctx, noise} = Context.get_sample(ctx, :main, :noise)

      {ctx, noise * osc1}
    end)

    WavWriter.close(writer)
  end
end
