defmodule Synthex do
  use Synthex.Math
  alias Synthex.Context

  def synthesize(ctx = %Context{rate: rate, time: t}, duration, func) do
    sample_count = t + duration_in_secs_to_sample_count(duration, rate)
    do_synthesize(ctx, sample_count, func)
  end

  defp do_synthesize(ctx = %Context{time: sample_count}, sample_count, _func), do: ctx
  defp do_synthesize(ctx = %Context{output: writer, time: t}, sample_count, func) do
    {ctx, samples} = func.(ctx)
    clamped_samples = clamp_all(samples)
    Synthex.Output.Writer.write_samples(writer, clamped_samples)

    ctx |> Map.put(:time, t + 1) |> do_synthesize(sample_count, func)
  end

  defp clamp_all(samples) when is_list(samples), do: Enum.map(samples, fn(sample) -> clamp(sample) end)
  defp clamp_all(sample), do: clamp(sample)
end
