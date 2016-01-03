defmodule Player do
  alias Synthex.Context
  alias Synthex.Input.WavReader
  alias Synthex.Output.SoxPlayer

  use Synthex.Math

  def run(path) do
    reader = WavReader.open(path, false)
    {:ok, writer} = SoxPlayer.open(rate: reader.header.rate, channels: reader.header.channels)
    context =
      %Context{output: writer, rate: reader.header.rate}
      |> Context.put_element(:main, :wav, reader)

    Synthex.synthesize(context, WavReader.get_duration(reader), fn (ctx) ->
      Context.get_sample(ctx, :main, :wav)
    end)

    SoxPlayer.close(writer)
  end
end

Player.run(hd(System.argv))