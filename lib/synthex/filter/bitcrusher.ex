defmodule Synthex.Filter.Bitcrusher do
 @moduledoc """
  Quantizer / Decimator with smooth control.

  bits must be between 1 and 16
  normalized_frequency (frequency / rate) must be between 0 and 1
  """

  use Synthex.Math

  alias Synthex.Filter.Bitcrusher

  defstruct [bits: 16, normalized_frequency: 1.0, sample: 0.0, last: 0.0, phaser: 0.0]

  def get_sample(_ctx, state = %Bitcrusher{bits: bits, normalized_frequency: normalized_frequency, sample: sample, last: last, phaser: phaser}) do
    step = :math.pow(1/2, bits)
    {phaser, last} = updated_state(phaser + normalized_frequency, last, sample, step)

    state = state |> Map.put(:phaser, phaser) |> Map.put(:last, last)
    {state, last}
  end

  defp updated_state(phaser, _last, sample, step) when phaser >= 1.0, do: {phaser - 1.0, step * Float.floor(sample / step + 0.5)}
  defp updated_state(phaser, last, _sample, _step), do: {phaser, last}
end