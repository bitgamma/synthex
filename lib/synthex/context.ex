defmodule Synthex.Context do
  alias Synthex.Context

  defstruct [rate: 44100, output: nil, blocks: %{}]

  def put_element(ctx = %Context{blocks: blocks}, block_name, element_name, element) do
    block = Map.get(blocks, block_name, %{}) |> Map.put(element_name, element)
    blocks = Map.put(blocks, block_name, block)
    Map.put(ctx, :blocks, blocks)
  end

  def get_element(%Context{blocks: blocks}, block_name, element_name, def_val \\ nil) do
    Map.get(blocks, block_name, %{}) |> Map.get(element_name, def_val)
  end
end