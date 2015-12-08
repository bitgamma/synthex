defmodule Synthex.Generator.Oscillator do
  use Synthex.Math

  alias Synthex.Context
  alias Synthex.Generator.Oscillator

  defstruct [algorithm: :sine, frequency: 220, sync_phase: @tau, phase: 0.0, center: @pi]

  def get_sample(%Context{rate: rate}, state = %Oscillator{algorithm: algorithm, frequency: frequency, sync_phase: sync_phase, phase: phase}) do
    sample = do_get_sample(algorithm, state)
    phase_delta = (@tau * frequency) / rate
    phase = calculate_phase(phase + phase_delta, sync_phase)
    {Map.put(state, :phase, phase), sample}
  end

  defp calculate_phase(phase, sync_phase) when phase >= sync_phase, do: phase - sync_phase
  defp calculate_phase(phase, _sync_phase), do: phase

  defp do_get_sample(:sine, %{phase: phase}), do: :math.sin(phase)
  defp do_get_sample(alg, %{phase: phase, center: center}) when alg in [:pulse, :square] and phase < center, do: 1.0
  defp do_get_sample(alg, _state) when alg in [:pulse, :square], do: -1.0
  defp do_get_sample(:sawtooth, %{phase: phase}), do: (@one_on_pi * phase) - 1.0
  defp do_get_sample(:reverse_sawtooth, %{phase: phase}), do: 1.0 - (@one_on_pi * phase)
  defp do_get_sample(:triangle, %{phase: phase, center: center}) when phase < center, do: -1.0 + (@two_on_pi * phase)
  defp do_get_sample(:triangle, %{phase: phase}), do: 3.0 - (@two_on_pi * phase)
  defp do_get_sample(func, state) when is_function(func), do: func.(state)
  defp do_get_sample({module, function}, state), do: apply(module, function, [state])
end