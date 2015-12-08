defmodule Binaural do
  alias Synthex.Context
  alias Synthex.Output.SoxPlayer
  alias Synthex.Generator.Oscillator
  alias Synthex.Generator.Noise
  use Synthex.Math

  @rate 44100
  @carrier 300
  @start_freq @carrier + 20
  @end_freq @carrier + 6
  @ramp_down_duration 600
  @ramp_down_freq 1/@ramp_down_duration
  @sustain_duration 1200

  def run(duration) do
    {:ok, writer} = SoxPlayer.open(rate: @rate, channels: 2)

    %Context{output: writer, rate: @rate}
    |> Context.put_element(:main, :osc1, %Oscillator{algorithm: :sine, frequency: @carrier})
    |> Context.put_element(:main, :osc2, %Oscillator{algorithm: :sine})
    |> Context.put_element(:main, :noise, %Noise{type: :brown})
    |> Context.put_element(:main, :lfo, %Oscillator{algorithm: :sawtooth, frequency: 0.2, phase: @pi})
    |> Context.put_element(:main, :freq, %Oscillator{algorithm: :reverse_sawtooth, frequency: @ramp_down_freq})
    |> rampdown()
    |> sustain()

    SoxPlayer.close(writer)
  end

  defp apply_noise(osc, noise, lfo) do
    (osc * 0.90) + (noise * 0.10 * lfo)
  end

  defp rampdown(context) do
    Synthex.synthesize(context, @ramp_down_duration, fn (ctx) ->
      {ctx, freq} = Context.get_sample(ctx, :main, :freq)

      {ctx, osc1} = Context.get_sample(ctx, :main, :osc1)
      {ctx, osc2} = Context.get_sample(ctx, :main, :osc2, %{frequency: amplitude_to_frequency(freq, @end_freq, @start_freq)})

      {ctx, noise} = Context.get_sample(ctx, :main, :noise)
      {ctx, lfo} = Context.get_sample(ctx, :main, :lfo)

      {ctx, [apply_noise(osc1, noise, lfo), apply_noise(osc2, noise, lfo)]}
    end)
  end

  defp sustain(context) do
    Synthex.synthesize(context, @sustain_duration, fn (ctx) ->
      {ctx, osc1} = Context.get_sample(ctx, :main, :osc1)
      {ctx, osc2} = Context.get_sample(ctx, :main, :osc2)

      {ctx, noise} = Context.get_sample(ctx, :main, :noise)
      {ctx, lfo} = Context.get_sample(ctx, :main, :lfo)

      {ctx, [apply_noise(osc1, noise, lfo), apply_noise(osc2, noise, lfo)]}
    end)
  end
end

Binaural.run()