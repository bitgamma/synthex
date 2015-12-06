defmodule Synthex do
  use Synthex.Math
  alias Synthex.Context

  def synthesize(ctx = %Context{rate: rate, time: t}, duration, func) do
    sample_count = t + duration_in_secs_to_sample_count(duration, rate)
    do_synthesize(ctx, sample_count, func)
  end

  defp do_synthesize(%Context{time: sample_count}, sample_count, _func), do: :ok
  defp do_synthesize(ctx = %Context{output: writer, time: t}, sample_count, func) do
    {ctx, sample} = func.(ctx)
    Synthex.Output.Writer.write_samples(writer, clamp(sample))

    ctx |> Map.put(:time, t + 1) |> do_synthesize(sample_count, func)
  end
end
