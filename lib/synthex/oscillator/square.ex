defmodule Synthex.Oscillator.Square do
  use Synthex.Math

  def init(opts) do
    frequency = Keyword.fetch!(opts, :frequency)
    rate = Keyword.fetch!(opts, :rate)

    phase_delta = (@tau * frequency) / rate
    %{phase_delta: phase_delta, period: (rate / frequency)}
  end

  def get_sample(%{phase_delta: phase_delta, period: period}, t) do
    phase = phase_delta * fmod(t, period)
    do_get_sample(phase)
  end

  defp do_get_sample(phase) when phase < @pi, do: 1.0
  defp do_get_sample(_), do: -1.0
end