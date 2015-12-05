defmodule Synthex.Generator.Noise do
  alias Synthex.Generator.Noise

  defstruct [type: :white, history: {0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0}]

  def get_sample(_ctx, state = %Noise{type: :white}), do: {state, get_random_sample()}
  def get_sample(_ctx, state = %Noise{type: :pink, history: {b0, b1, b2, b3, b4, b5, b6}}) do
    white = get_random_sample()

    b0 = 0.99886 * b0 + white * 0.0555179
    b1 = 0.99332 * b1 + white * 0.0750759
    b2 = 0.96900 * b2 + white * 0.1538520
    b3 = 0.86650 * b3 + white * 0.3104856
    b4 = 0.55000 * b4 + white * 0.5329522
    b5 = -0.7616 * b5 - white * 0.0168980

    pink = b0 + b1 + b2 + b3 + b4 + b5 + b6 + white * 0.5362

    b6 = white * 0.115926

    {Map.put(state, :history, {b0, b1, b2, b3, b4, b5, b6}), pink * 0.11}
  end
  def get_sample(_ctx, state = %Noise{type: :brown, history: {b0, _, _, _, _, _, _}}) do
    white = get_random_sample()
    brown = (b0 + (0.02 * white)) / 1.02

    {Map.put(state, :history, {brown, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0}), brown * 3.5}
  end

  defp get_random_sample do
    :rand.uniform() * 2 - 1
  end
end