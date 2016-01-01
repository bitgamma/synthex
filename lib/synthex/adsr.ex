defmodule Synthex.ADSR do
  alias Synthex.ADSR

  defstruct [gate: :off, state: :idle, out: 0.0, prev_gate: :off, sustain_level: 1.0, attack_base: 0.0, attack_coefficient: 0.0, decay_base: 0.0, decay_coefficient: 0.0, release_base: 0.0, release_coefficient: 0.0]

  def get_sample(_ctx, adsr = %ADSR{gate: gate, state: state, prev_gate: prev_gate}) do
    new_state = get_transition(prev_gate, gate, state)
    {next_state, out} = process(new_state, adsr)
    {%ADSR{adsr | state: next_state, out: out, prev_gate: gate}, out}
  end

  defp process(:idle, _adsr), do: {:idle, 0.0}
  defp process(:attack, %ADSR{attack_base: attack_base, attack_coefficient: attack_coefficient, out: out}) do
    new_out = attack_base + (out * attack_coefficient)
    process_attack(new_out)
  end
  defp process(:decay, %ADSR{decay_base: decay_base, decay_coefficient: decay_coefficient, out: out, sustain_level: sustain_level}) do
    new_out = decay_base + (out * decay_coefficient)
    process_decay(new_out, sustain_level)
  end
  defp process(:sustain, %ADSR{sustain_level: sustain_level}), do: {:sustain, sustain_level}
  defp process(:release, %ADSR{release_base: release_base, release_coefficient: release_coefficient, out: out}) do
    new_out = release_base + (out * release_coefficient)
    process_release(new_out)
  end

  defp process_attack(out) when out >= 1.0, do: {:decay, 1.0}
  defp process_attack(out), do: {:attack, out}

  defp process_decay(out, sustain_level) when out <= sustain_level, do: {:sustain, sustain_level}
  defp process_decay(out, _sustain_level), do: {:decay, out}

  defp process_release(out) when out <= 0.0, do: {:idle, 0.0}
  defp process_release(out), do: {:release, out}

  defp get_transition(:off, :on, _), do: :attack
  defp get_transition(:on, :off, _), do: :release
  defp get_transition(_prev, _gate, state), do: state

  def adsr(rate, sustain_level, attack_duration, decay_duration, release_duration, target_ratio_A \\ 0.3, target_ratio_DR \\ 0.0001) do
    {attack_base, attack_coefficient} = calculate_base_and_coefficient(rate, 1.0, attack_duration, target_ratio_A)
    {decay_base, decay_coefficient} = calculate_base_and_coefficient(rate, sustain_level, decay_duration, -target_ratio_DR)
    {release_base, release_coefficient} = calculate_base_and_coefficient(rate, 0.0, release_duration, -target_ratio_DR)

    %ADSR{sustain_level: sustain_level, attack_base: attack_base, attack_coefficient: attack_coefficient, decay_base: decay_base, decay_coefficient: decay_coefficient, release_base: release_base, release_coefficient: release_coefficient}
  end

  def amplification_to_gate(amp) when amp > 0.0, do: :on
  def amplification_to_gate(_amp), do: :off

  defp calculate_coefficient(rate, target_ratio), do: :math.exp(-:math.log((1.0 + target_ratio) / target_ratio) / rate)

  defp calculate_base_and_coefficient(rate, target_level, duration, target_ratio) do
    target_rate = duration * rate
    coefficient = calculate_coefficient(target_rate, abs(target_ratio))
    base = (target_level + target_ratio) * (1.0 - coefficient)
    {base, coefficient}
  end
end