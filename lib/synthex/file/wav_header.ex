defmodule Synthex.File.WavHeader do
  require Integer

  defstruct [format: :lpcm, channels: 2, rate: 44100, sample_size: 16, data_chunk_size: 0]
  @wave_chunk_size 16

  def write(%Synthex.File.WavHeader{format: format, channels: channels, rate: rate, sample_size: sample_size, data_chunk_size: data_chunk_size}, io) do
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

  def read(io) do
    {:ok, "RIFF"} = :file.read(io, 4)
    {:ok, _full_size} = :file.read(io, 4)
    {:ok, "WAVEfmt "} = :file.read(io, 8)
    {:ok, <<wave_chunk_size::little-integer-size(32)>>} = :file.read(io, 4)
    {:ok, <<encoded_format::little-integer-size(16)>>} = :file.read(io, 2)
    {:ok, <<channels::little-integer-size(16)>>} = :file.read(io, 2)
    {:ok, <<rate::little-integer-size(32)>>} = :file.read(io, 4)
    {:ok, _avg_bytes_per_sec} = :file.read(io, 4)
    {:ok, _block_align} = :file.read(io, 2)
    {:ok, <<sample_size::little-integer-size(16)>>} = :file.read(io, 2)
    {:ok, _} = :file.position(io, {:cur, wave_chunk_size - @wave_chunk_size})

    data_chunk_size = find_data_chunk(io)
    format = decoded_format(encoded_format)
    %Synthex.File.WavHeader{format: format, channels: channels, rate: rate, sample_size: sample_size, data_chunk_size: data_chunk_size}
  end

  defp find_data_chunk(io) do
    {:ok, chunk_name} = :file.read(io, 4)
    {:ok, <<chunk_size::little-integer-size(32)>>} = :file.read(io, 4)

    if chunk_name == "data" do
      chunk_size
    else
      :file.position(io, {:cur, chunk_size})
      find_data_chunk(io)
    end
  end

  defp padding_length(data_chunk_size) when Integer.is_even(data_chunk_size), do: 1
  defp padding_length(_data_chunk_size), do: 0

  defp encoded_format(:lpcm), do: 0x0001
  defp encoded_format(:float), do: 0x0003

  defp decoded_format(0x0001), do: :lpcm
  defp decoded_format(0x0003), do: :float

end