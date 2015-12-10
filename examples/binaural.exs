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
  @rampdown_duration 600
  @rampdown_freq 1/@rampdown_duration
  @sustain_duration 1200

  def run() do
    {:ok, writer} = SoxPlayer.open(rate: @rate, channels: 2)

    %Context{output: writer, rate: @rate}
    |> Context.put_element(:main, :osc1, %Oscillator{algorithm: :sine, frequency: @carrier})
    |> Context.put_element(:main, :osc2, %Oscillator{algorithm: :sine})
    |> Context.put_element(:main, :noise, %Noise{type: :brown})
    |> Context.put_element(:main, :lfo, %Oscillator{algorithm: :sawtooth, frequency: 0.2, phase: @pi})
    |> Context.put_element(:main, :freq, %Oscillator{algorithm: :reverse_sawtooth, frequency: @rampdown_freq})
    |> rampdown()
    |> sustain()

    SoxPlayer.close(writer)
  end

  defp apply_noise(osc, noise, lfo) do
    (osc * 0.90) + (noise * 0.10 * lfo)
  end

  defp rampdown(context) do
    synth_phase(context, @rampdown_duration, fn (ctx) ->
      {ctx, freq} = Context.get_sample(ctx, :main, :freq)
      Context.get_sample(ctx, :main, :osc2, %{frequency: amplitude_to_frequency(freq, @end_freq, @start_freq)})
    end)
  end

  defp sustain(context) do
    synth_phase(context, @rampdown_duration, fn (ctx) -> Context.get_sample(ctx, :main, :osc2) end)
  end

  defp synth_phase(context, duration, osc2_func) do
    Synthex.synthesize(context, duration, fn (ctx) ->
      {ctx, osc2} = osc2_func.(ctx)
      {ctx, osc1} = Context.get_sample(ctx, :main, :osc1)

      {ctx, noise} = Context.get_sample(ctx, :main, :noise)
      {ctx, lfo} = Context.get_sample(ctx, :main, :lfo)

      {ctx, [apply_noise(osc1, noise, lfo), apply_noise(osc2, noise, lfo)]}
    end)
  end
end

Binaural.run()