defmodule Synthex do
  alias Synthex.Context

  def synthesize(ctx = %Context{rate: rate}, duration, func) do
    do_synthesize(ctx, rate * duration, func, 0)
  end

  defp do_synthesize(_ctx, sample_count, _func, sample_count), do: :ok
  defp do_synthesize(ctx = %Context{output: writer}, sample_count, func, t) do
    {ctx, sample} = func.(ctx, t)
    Synthex.Output.Writer.write_samples(writer, sample)
    do_synthesize(ctx, sample_count, func, t + 1)
  end
end
