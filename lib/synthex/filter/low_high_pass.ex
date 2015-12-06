defmodule Synthex.Filter.LowHighPass do
  use Synthex.Math

  alias Synthex.Context
  alias Synthex.Filter.LowHighPass

  defstruct [type: :lowpass, cutoff: 220, sample: 0.0, history: nil]

  def get_sample(%Context{rate: rate}, state = %LowHighPass{type: type, cutoff: cutoff, sample: sample, history: history}) do
    rc = 1.0 / (cutoff * @tau)
    dt = 1.0 / rate
    alpha = calculate_alpha(type, dt, rc)
    filtered_sample = do_get_sample(type, alpha, sample, history)

    {Map.put(state, :history, {filtered_sample, sample}), filtered_sample}
  end

  defp calculate_alpha(:lowpass, dt, rc), do: dt / (rc + dt)
  defp calculate_alpha(:highpass, dt, rc), do: rc / (rc + dt)

  defp do_get_sample(_type, _alpha, sample, nil), do: sample
  defp do_get_sample(:lowpass, alpha, sample, {prev_filtered, _}), do: prev_filtered + alpha * (sample - prev_filtered)
  defp do_get_sample(:highpass, alpha, sample, {prev_filtered, prev}), do: alpha * (prev_filtered + sample - prev)

end