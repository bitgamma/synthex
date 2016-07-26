defmodule Sine do
  alias Synthex.Context
  alias Synthex.Output.SoxPlayer
  alias Synthex.Generator.Oscillator

  @rate 44100

  def run(duration, frequency) do
    {:ok, writer} = SoxPlayer.open(rate: @rate, channels: 2)

    context =
      %Context{output: writer, rate: @rate}
      |> Context.put_element(:main, :osc1, %Oscillator{algorithm: :sine, frequency: frequency})

    Synthex.synthesize(context, duration, fn (ctx) ->
      Context.get_sample(ctx, :main, :osc1)
    end)

    SoxPlayer.close(writer)
  end
end

Sine.run(5, 440)
