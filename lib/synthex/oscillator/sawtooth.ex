defmodule Synthex.Oscillator.Sawtooth do
  require Synthex.Math

  def init(opts) do
    frequency = Keyword.fetch!(opts, :frequency)
    rate = Keyword.fetch!(opts, :rate)
    pi = :math.pi()
    phase_delta = (2 * pi * frequency) / rate
    one_on_pi = 1/pi
    %{phase_delta: phase_delta, one_on_pi: one_on_pi, period: (rate / frequency)}
  end

  def get_sample(%{phase_delta: phase_delta, period: period, one_on_pi: one_on_pi}, t) do
    phase = phase_delta * Synthex.Math.fmod(t, period)
    1.0 - (one_on_pi * phase)
  end
end