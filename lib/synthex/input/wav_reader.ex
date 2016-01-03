defmodule Synthex.Input.WavReader do
  alias Synthex.Input.WavReader
  alias Synthex.File.WavHeader

  defstruct [file: nil, header: nil, loop: true, data_offset: 0, pos: 0]

  def get_sample(_ctx, state = %WavReader{file: file, header: header, loop: loop, data_offset: data_offset, pos: pos}) do
    eof = (pos == :none) || (pos >= (header.data_chunk_size + data_offset))
    pos = read_position(pos, eof, loop, data_offset)
    {new_pos, samples} = read_samples(file, pos, header)
    {Map.put(state, :pos, new_pos), samples}
  end

  def open(path, loop \\ true) do
    {:ok, file} = :file.open(path, [:read, :binary, :read_ahead])
    header = WavHeader.read(file)
    {:ok, data_offset} = :file.position(file, {:cur, 0})
    %WavReader{file: file, header: header, loop: loop, data_offset: data_offset, pos: data_offset}
  end

  def get_duration(reader = %WavReader{header: %WavHeader{rate: rate}}) do
    get_sample_count(reader) / rate
  end

  def get_sample_count(%WavReader{header: %WavHeader{data_chunk_size: data_chunk_size, channels: channels, sample_size: sample_size}}) do
    div(data_chunk_size, (div(sample_size, 8) * channels))
  end

  defp read_position(pos, false, _, _), do: pos
  defp read_position(_, true, true, data_offset), do: data_offset
  defp read_position(_, true, false, _), do: :none

  defp read_samples(_file, :none, %WavHeader{channels: channels}), do: {:none, Enum.map(1..channels, fn(_) -> 0.0 end)}
  defp read_samples(file, pos, %WavHeader{sample_size: sample_size, format: format, channels: channels}) do
    to_read = div(sample_size, 8) * channels
    {:ok, data} = :file.read(file, to_read)
    {pos + to_read, decode_samples(data, sample_size, format, [])}
  end

  defp decode_samples("", _sample_size, _format, decoded_samples), do: Enum.reverse(decoded_samples)
  defp decode_samples(data, sample_size, :lpcm, decoded_samples) do
    <<sample::little-integer-size(sample_size), rest::binary>> = data
    decode_samples(rest, sample_size, :lpcm, [int_to_float_sample(sample, sample_size) | decoded_samples])
  end
  defp decode_samples(<<sample::little-float-size(32), rest::binary>>, 32, :float, decoded_samples) do
    decode_samples(rest, 32, :float, [sample | decoded_samples])
  end

  defp int_to_float_sample(sample, 8) when sample < 0, do: sample / 128
  defp int_to_float_sample(sample, 8), do: sample / 127
  defp int_to_float_sample(sample, 16) when sample < 0, do: sample / 32768
  defp int_to_float_sample(sample, 16), do: sample / 32767
  defp int_to_float_sample(sample, 24) when sample < 0, do: sample / 8388608
  defp int_to_float_sample(sample, 24), do: sample / 8388607
  defp int_to_float_sample(sample, 32) when sample < 0, do: sample / 2147483648
  defp int_to_float_sample(sample, 32), do: sample / 2147483647
end