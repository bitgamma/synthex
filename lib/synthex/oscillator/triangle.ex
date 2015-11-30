defmodule Synthex.Oscillator.Triangle do
  use Synthex.Math

  def init(opts) do
    frequency = Keyword.fetch!(opts, :frequency)
    rate = Keyword.fetch!(opts, :rate)

    phase_delta = (@tau * frequency) / rate
    %{phase_delta: phase_delta, period: (rate / frequency)}
  end

  def get_sample(%{phase_delta: phase_delta, period: period}, t) do
    phase = phase_delta * fmod(t, period)
    phase_offset = @two_on_pi * phase
    do_get_sample(phase, phase_offset)
  end

  defp do_get_sample(phase, phase_offset) when phase < @pi, do: -1.0 + phase_offset
  defp do_get_sample(_phase, phase_offset), do: 3.0 - phase_offset
end