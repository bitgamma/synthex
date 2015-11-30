defmodule Synthex.Output.WavHeader do
  require Integer

  defstruct [format: :lpcm, channels: 2, rate: 44100, sample_size: 16]
  @wave_chunk_size 16

  def write(%Synthex.Output.WavHeader{format: format, channels: channels, rate: rate, sample_size: sample_size}, io, data_chunk_size) do
    sample_size_bytes = div(sample_size, 8)
    full_size = (4 + 24 + 8 + data_chunk_size) + padding_length(data_chunk_size)
    encoded_format = encoded_format(format)
    block_align = sample_size_bytes * channels
    avg_bytes_per_sec = rate * block_align

    :ok = :file.write(io, "RIFF")
    :ok = :file.write(io, <<full_size::little-integer-size(32)>>)
    :ok = :file.write(io, "WAVEfmt ")
    :ok = :file.write(io, <<@wave_chunk_size::little-integer-size(32)>>)
    :ok = :file.write(io, <<encoded_format::little-integer-size(16)>>)
    :ok = :file.write(io, <<channels::little-integer-size(16)>>)
    :ok = :file.write(io, <<rate::little-integer-size(32)>>)
    :ok = :file.write(io, <<avg_bytes_per_sec::little-integer-size(32)>>)
    :ok = :file.write(io, <<block_align::little-integer-size(16)>>)
    :ok = :file.write(io, <<sample_size::little-integer-size(16)>>)
    :ok = :file.write(io, "data")
    :ok = :file.write(io, <<data_chunk_size::little-integer-size(32)>>)
  end

  defp padding_length(data_chunk_size) when Integer.is_even(data_chunk_size), do: 1
  defp padding_length(_data_chunk_size), do: 0

  defp encoded_format(:lpcm), do: 0x0001

end

defmodule Synthex.Output.WavWriter do
  use GenServer

  @header_length 44

  def open(path, header \\ %Synthex.Output.WavHeader{}) do
    GenServer.start_link(__MODULE__, %{path: path, header: header})
  end

  def write_samples(writer, samples) do
    GenServer.call(writer, {:write_samples, encode_samples(samples)})
  end

  def close(writer) do
    GenServer.call(writer, :close)
  end

  defp encode_samples(samples) when is_list(samples) do
    Enum.reduce(samples, <<>>, fn(sample, acc) -> acc <> <<sample::little-integer-size(16)>> end)
  end
  defp encode_samples(sample) do
    <<sample::little-integer-size(16)>>
  end

  def init(%{path: path, header: header}) do
    {:ok, file} = :file.open(path, [:write, :raw, :binary, :delayed_write])
    {:ok, _} = :file.position(file, @header_length)

    {:ok, %{header: header, file: file, data_chunk_size: 0}}
  end

  def handle_call({:write_samples, samples}, _from, state = %{file: file, data_chunk_size: data_chunk_size}) do
    :ok = :file.write(file, samples)
    {:reply, :ok, %{state | data_chunk_size: data_chunk_size + byte_size(samples)}}
  end
  def handle_call(:close, _from, state = %{file: file, header: header, data_chunk_size: data_chunk_size}) do
    {:ok, _} = :file.position(file, :bof)
    :ok = Synthex.Output.WavHeader.write(header, file, data_chunk_size)
    :ok = :file.close(file)
    {:stop, :normal, state}
  end
end