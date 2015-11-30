defmodule Synthex.Oscillator.Sawtooth do
  use Synthex.Math

  def init(opts) do
    frequency = Keyword.fetch!(opts, :frequency)
    rate = Keyword.fetch!(opts, :rate)

    phase_delta = (@tau * frequency) / rate
    %{phase_delta: phase_delta, period: (rate / frequency)}
  end

  def get_sample(%{phase_delta: phase_delta, period: period}, t) do
    phase = phase_delta * fmod(t, period)
    1.0 - (@one_on_pi * phase)
  end
end