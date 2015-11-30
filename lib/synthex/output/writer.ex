defmodule Synthex.Output.Writer do
  def write_samples(writer, samples) do
    GenServer.call(writer, {:write_samples, samples})
  end
end