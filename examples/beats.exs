defmodule Beats do
  alias Synthex.Context
  alias Synthex.Output.SoxPlayer
  alias Synthex.Generator.Oscillator
  alias Synthex.Generator.Noise
  use Synthex.Math

  @rate 44100

  def run(duration) do
    {:ok, writer} = SoxPlayer.open(rate: @rate, channels: 1)

    context =
      %Context{output: writer, rate: @rate}
      |> Context.put_element(:main, :osc1, %Oscillator{algorithm: :sawtooth, frequency: 1, sync_phase: @pi})
      |> Context.put_element(:main, :osc2, %Oscillator{algorithm: :pulse, frequency: 0.5, center: duty_cycle_to_radians(0.75)})
      |> Context.put_element(:main, :osc3, %Oscillator{algorithm: :triangle, frequency: 0.02})
      |> Context.put_element(:main, :noise, %Noise{type: :brown})

    Synthex.synthesize(context, duration, fn (ctx) ->
      {ctx, osc3} = Context.get_sample(ctx, :main, :osc3)

      {ctx, osc1} = Context.get_sample(ctx, :main, :osc1, %{frequency: amplitude_to_frequency(osc3, 0.8, 4)})
      {ctx, osc2} = Context.get_sample(ctx, :main, :osc2, %{frequency: amplitude_to_frequency(osc3, 0.4, 2)})
      {ctx, noise} = Context.get_sample(ctx, :main, :noise)

      {ctx, osc1 * noise * shift_by(osc2, 1)}
    end)
    SoxPlayer.close(writer)
  end
end

Beats.run(20)