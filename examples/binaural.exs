defmodule Binaural do
  alias Synthex.Context
  alias Synthex.Output.SoxPlayer
  alias Synthex.Generator.Oscillator
  alias Synthex.Generator.Noise
  use Synthex.Math

  @rate 44100

  def run(duration) do
    {:ok, writer} = SoxPlayer.open(rate: @rate, channels: 2)

    context =
      %Context{output: writer, rate: @rate}
      |> Context.put_element(:main, :osc1, %Oscillator{algorithm: :sine, frequency: 220})
      |> Context.put_element(:main, :osc2, %Oscillator{algorithm: :sine, frequency: 228})
      |> Context.put_element(:main, :noise, %Noise{type: :pink})

    Synthex.synthesize(context, duration, fn (ctx) ->
      {ctx, osc1} = Context.get_sample(ctx, :main, :osc1)
      {ctx, osc2} = Context.get_sample(ctx, :main, :osc2)

      {ctx, noise} = Context.get_sample(ctx, :main, :noise)

      {ctx, [(osc1 * 0.95) + (noise * 0.05), (osc2 * 0.95) + (noise * 0.05)]}
    end)
    SoxPlayer.close(writer)
  end
end

Binaural.run(20)