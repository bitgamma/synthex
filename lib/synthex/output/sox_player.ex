defmodule Synthex.Output.SoxPlayer do
  @moduledoc """
  Outputs to SoX player. SoX must be installed on the system beforehand and must be in the PATH environment variable.
  """

  use GenServer

  def open(opts) do
    rate = Keyword.get(opts, :rate, 44100)
    channels = Keyword.get(opts, :channels, 2)

    GenServer.start_link(__MODULE__, %{rate: rate, channels: channels})
  end

  def close(player) do
    GenServer.cast(player, :close)
  end

  def init(%{rate: rate, channels: channels}) do
    args = ['-q', '-t', 'raw', '-L', '-b', '32', '-e', 'floating-point', '-r', Integer.to_char_list(rate), '-c', Integer.to_char_list(channels), '-']
    play = :os.find_executable('play')
    port = Port.open({:spawn_executable, play}, [{:args, args}, :binary, :out, :stream])
    {:ok, %{port: port}}
  end

  def handle_call({:write_samples, samples}, _from, state = %{port: port}) do
    encoded_samples = encode_samples(samples)
    Port.command(port, encoded_samples)
    {:reply, :ok, state}
  end

  def handle_cast(:close, state) do
    {:stop, :normal, state}
  end

  defp encode_samples(samples) when is_list(samples) do
    Enum.reduce(samples, <<>>, fn(sample, acc) -> acc <> encode_samples(sample) end)
  end
  defp encode_samples(sample) do
    <<sample::little-float-size(32)>>
  end
end