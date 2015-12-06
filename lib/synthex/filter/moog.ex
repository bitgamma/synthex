defmodule Synthex.Filter.Moog do
  @moduledoc """
  Emulates the Moog VCF.

  cutoff must be between 0 and 1
  resonance must be between 0 and 4
  """
  use Synthex.Math

  alias Synthex.Filter.Moog

  defstruct [cutoff: 1, resonance: 0, sample: 0.0, in: {0.0, 0.0, 0.0, 0.0}, out: {0.0, 0.0, 0.0, 0.0}]

  def get_sample(_ctx, state = %Moog{cutoff: cutoff, resonance: resonance, sample: sample, in: {i1, i2, i3, i4}, out: {o1, o2, o3, o4}}) do
    f = cutoff * 1.16
    f_squared = f * f
    fb = resonance * (1.0 - 0.15 * f_squared)
    sample = sample - o4 * fb
    sample = sample * 0.35013 * f_squared * f_squared
    o1 = sample + 0.3 * i1 + (1 - f) * o1
    o2 = o1 + 0.3 * i2 + (1 - f) * o2
    o3 = o2 + 0.3 * i3 + (1 - f) * o3
    o4 = o3 + 0.3 * i4 + (1 - f) * o4

    state =
      state
      |> Map.put(:in, {sample, o1, o2, o3})
      |> Map.put(:out, {o1, o2, o3, o4})

    {state, o4}
  end


end