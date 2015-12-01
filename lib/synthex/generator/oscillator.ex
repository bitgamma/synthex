defmodule Synthex.Generator.Oscillator do
  use Synthex.Math

  alias Synthex.Context
  alias Synthex.Generator.Oscillator

  defstruct [algorithm: :sine, frequency: 220, sync_frequency: :none, offset: 0]

  def generate_sample(%Context{rate: rate}, state = %Oscillator{algorithm: algorithm, frequency: frequency, sync_frequency: sync_frequency, offset: offset}, t) do
    phase_delta = (@tau * frequency) / rate
    offset_time = offset / phase_delta
    period = calculate_period(rate, frequency, sync_frequency)
    phase = phase_delta * fmod(t + offset_time, period)
    {state, do_generate_sample(algorithm, phase)}
  end

  defp calculate_period(rate, frequency, :none), do: rate / frequency
  defp calculate_period(rate, _frequency, sync_frequency), do: rate / sync_frequency

  defp do_generate_sample(:sine, phase), do: :math.sin(phase)
  defp do_generate_sample(:square, phase) when phase < @pi, do: 1.0
  defp do_generate_sample(:square, _phase), do: -1.0
  defp do_generate_sample(:sawtooth, phase), do: 1.0 - (@one_on_pi * phase)
  defp do_generate_sample(:triangle, phase) when phase < @pi, do: -1.0 + (@two_on_pi * phase)
  defp do_generate_sample(:triangle, phase), do: 3.0 - (@two_on_pi * phase)
  defp do_generate_sample(func, phase) when is_function(func), do: func.(phase)
  defp do_generate_sample({module, function}, phase), do: apply(module, function, [phase])
end