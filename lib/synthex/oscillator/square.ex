defmodule Synthex.Oscillator.Square do
  require Synthex.Math

  def init(opts) do
    frequency = Keyword.fetch!(opts, :frequency)
    rate = Keyword.fetch!(opts, :rate)
    phase_delta = (2 * :math.pi() * frequency) / rate

    %{phase_delta: phase_delta, period: (rate / frequency)}
  end

  def get_sample(%{phase_delta: phase_delta, period: period}, t) do
    phase = phase_delta * Synthex.Math.fmod(t, period)
    do_get_sample(phase, :math.pi())
  end

  defp do_get_sample(phase, pi) when phase < pi, do: 1.0
  defp do_get_sample(_, _), do: -1.0
end