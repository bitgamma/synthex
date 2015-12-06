defmodule Filter do
  alias Synthex.Context
  alias Synthex.Output.WavWriter
  alias Synthex.Output.WavHeader
  alias Synthex.Generator.Noise
  alias Synthex.Filter.LowHighPass
  use Synthex.Math

  def run(duration) do
    header = %WavHeader{channels: 1}
    {:ok, writer} = WavWriter.open(System.user_home() <> "/filter.wav", header)
    context =
      %Context{output: writer, rate: header.rate}
      |> Context.put_element(:main, :noise, %Noise{type: :white})
      |> Context.put_element(:main, :filter, %LowHighPass{type: :lowpass, cutoff: 220})

    Synthex.synthesize(context, duration, fn (ctx) ->
      {ctx, noise} = Context.get_sample(ctx, :main, :noise)
      {ctx, filtered} = Context.get_sample(ctx, :main, :filter, %{sample: noise})

      {ctx, filtered}
    end)

    WavWriter.close(writer)
  end
end

Filter.run(5)
:timer.sleep(1000)