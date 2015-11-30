defmodule Synthex do
  def synthesize(writer, sample_count, func) do
    do_synthesize(writer, sample_count, func, 0)
  end

  defp do_synthesize(writer, sample_count, func, sample_count), do: :ok
  defp do_synthesize(writer, sample_count, func, t) do
    sample = func.(t)
    Synthex.Output.Writer.write_samples(writer, sample)
    do_synthesize(writer, sample_count, func, t + 1)
  end
end
