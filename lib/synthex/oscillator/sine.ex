defmodule Synthex.Oscillator.Sine do
  def init(opts) do
    frequency = Keyword.fetch!(opts, :frequency)
    rate = Keyword.fetch!(opts, :rate)

    phase_delta = (2 * :math.pi() * frequency) / rate
    %{phase_delta: phase_delta}
  end

  def get_sample(%{phase_delta: phase_delta}, t) do
    :math.sin(phase_delta * t)
  end
end