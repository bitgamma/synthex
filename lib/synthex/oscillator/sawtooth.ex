defmodule Synthex.Oscillator.Sawtooth do
  def init(opts) do
    frequency = Keyword.fetch!(opts, :frequency)
    rate = Keyword.fetch!(opts, :rate)
    pi = :math.pi()
    phase_delta = (2 * pi * frequency) / rate
    one_on_pi = 1/pi
    %{phase_delta: phase_delta, one_on_pi: one_on_pi, period: round(rate / frequency)}
  end

  def get_sample(%{phase_delta: phase_delta, period: period, one_on_pi: one_on_pi}, t) do
    phase = phase_delta * rem(t, period)
    1 - (one_on_pi * phase)
  end
end