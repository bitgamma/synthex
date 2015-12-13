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
    |> Context.put_element(:carrier, :osc, %Oscillator{algorithm: :sine, frequency: @carrier})
    |> Context.put_element(:signal, :osc, %Oscillator{algorithm: :sine})
    |> Context.put_element(:signal, :freq, %Oscillator{algorithm: :reverse_sawtooth, frequency: @rampdown_freq})
    |> Context.put_element(:background, :noise, %Noise{type: :brown})
    |> Context.put_element(:background, :lfo, %Oscillator{algorithm: :sawtooth, frequency: 0.2, phase: @pi})
    |> rampdown()
    |> sustain()

    SoxPlayer.close(writer)
  end

  defp rampdown(context) do
    synth_phase(context, @rampdown_duration, fn (ctx) ->
      {ctx, freq} = Context.get_sample(ctx, :signal, :freq)
      Context.get_sample(ctx, :signal, :osc, %{frequency: amplitude_to_frequency(freq, @end_freq, @start_freq)})
    end)
  end

  defp sustain(context) do
    synth_phase(context, @rampdown_duration, fn (ctx) -> Context.get_sample(ctx, :signal, :osc) end)
  end

  defp mix(front, back), do: (front * 0.90) + (back * 0.10)

  defp get_background(ctx) do
    {ctx, noise} = Context.get_sample(ctx, :background, :noise)
    {ctx, lfo} = Context.get_sample(ctx, :background, :lfo)
    {ctx, (noise * lfo)}
  end

  defp synth_phase(context, duration, signal_func) do
    Synthex.synthesize(context, duration, fn (ctx) ->
      {ctx, signal} = signal_func.(ctx)
      {ctx, carrier} = Context.get_sample(ctx, :carrier, :osc)
      {ctx, background} = get_background(ctx)

      {ctx, [mix(carrier, background), mix(signal, background)]}
    end)
  end
end

Binaural.run()