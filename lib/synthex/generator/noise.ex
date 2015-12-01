defmodule Synthex.Generator.Noise do
  alias Synthex.Generator.Noise

  defstruct [type: :white]

  def get_sample(_ctx, state = %Noise{type: :white}) do
    {state, :random.uniform() * 2 - 1}
  end
end