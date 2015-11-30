defmodule Synthex.Oscillator.Triangle do
  require Synthex.Math

  def init(opts) do
    frequency = Keyword.fetch!(opts, :frequency)
    rate = Keyword.fetch!(opts, :rate)
    pi = :math.pi()
    phase_delta = (2 * pi * frequency) / rate
    two_on_pi = 2/pi
    %{phase_delta: phase_delta, two_on_pi: two_on_pi, period: (rate / frequency)}
  end

  def get_sample(%{phase_delta: phase_delta, period: period, two_on_pi: two_on_pi}, t) do
    phase = phase_delta * Synthex.Math.fmod(t, period)
    phase_offset = two_on_pi * phase
    do_get_sample(phase, :math.pi(), phase_offset)
  end

  defp do_get_sample(phase, pi, phase_offset) when phase < pi, do: -1.0 + phase_offset
  defp do_get_sample(_phase, _pi, phase_offset), do: 3.0 - phase_offset
end