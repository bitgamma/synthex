defmodule Synthex.Generator.Oscillator do
  use Synthex.Math

  alias Synthex.Context
  alias Synthex.Generator.Oscillator

  defstruct [algorithm: :sine, frequency: 220, sync_frequency: :none, offset: 0, center: @pi]

  def get_sample(%Context{rate: rate, time: t}, state = %Oscillator{algorithm: algorithm, frequency: frequency, sync_frequency: sync_frequency, offset: offset}) do
    phase_delta = (@tau * frequency) / rate
    offset_time = offset / phase_delta
    period = calculate_period(rate, frequency, sync_frequency)
    phase = phase_delta * fmod(t + offset_time, period)
    {state, do_get_sample(algorithm, state, phase)}
  end

  defp calculate_period(rate, frequency, :none), do: rate / frequency
  defp calculate_period(rate, _frequency, sync_frequency), do: rate / sync_frequency

  defp do_get_sample(:sine, _state, phase), do: :math.sin(phase)
  defp do_get_sample(alg, %{center: center}, phase) when alg in [:pulse, :square] and phase < center, do: 1.0
  defp do_get_sample(alg, _state, _phase) when alg in [:pulse, :square], do: -1.0
  defp do_get_sample(:sawtooth, _state, phase), do: 1.0 - (@one_on_pi * phase)
  defp do_get_sample(:triangle, %{center: center}, phase) when phase < center, do: -1.0 + (@two_on_pi * phase)
  defp do_get_sample(:triangle, _state, phase), do: 3.0 - (@two_on_pi * phase)
  defp do_get_sample(func, state, phase) when is_function(func), do: func.(state, phase)
  defp do_get_sample({module, function}, state, phase), do: apply(module, function, [state, phase])
end