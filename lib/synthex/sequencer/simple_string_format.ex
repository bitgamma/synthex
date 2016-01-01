defmodule Synthex.Sequencer.SimpleStringFormat do
  alias Synthex.Sequencer

  @notes %{
    "c8" => 4186.01,
    "b7" => 3951.07,
    "A7" => 3729.31,
    "a7" => 3520.00,
    "G7" => 3322.44,
    "g7" => 3135.96,
    "F7" => 2959.96,
    "f7" => 2793.83,
    "e7" => 2637.02,
    "D7" => 2489.02,
    "d7" => 2349.32,
    "C7" => 2217.46,
    "c7" => 2093.00,
    "b6" => 1975.53,
    "A6" => 1864.66,
    "a6" => 1760.00,
    "G6" => 1661.22,
    "g6" => 1567.98,
    "F6" => 1479.98,
    "f6" => 1396.91,
    "e6" => 1318.51,
    "D6" => 1244.51,
    "d6" => 1174.66,
    "C6" => 1108.73,
    "c6" => 1046.50,
    "b5" => 987.767,
    "A5" => 932.328,
    "a5" => 880.000,
    "G5" => 830.609,
    "g5" => 783.991,
    "F5" => 739.989,
    "f5" => 698.456,
    "e5" => 659.255,
    "D5" => 622.254,
    "d5" => 587.330,
    "C5" => 554.365,
    "c5" => 523.251,
    "b4" => 493.883,
    "A4" => 466.164,
    "a4" => 440.000,
    "G4" => 415.305,
    "g4" => 391.995,
    "F4" => 369.994,
    "f4" => 349.228,
    "e4" => 329.628,
    "D4" => 311.127,
    "d4" => 293.665,
    "C4" => 277.183,
    "c4" => 261.626,
    "b3" => 246.942,
    "A3" => 233.082,
    "a3" => 220.000,
    "G3" => 207.652,
    "g3" => 195.998,
    "F3" => 184.997,
    "f3" => 174.614,
    "e3" => 164.814,
    "D3" => 155.563,
    "d3" => 146.832,
    "C3" => 138.591,
    "c3" => 130.813,
    "b2" => 123.471,
    "A2" => 116.541,
    "a2" => 110.000,
    "g2" => 97.9989,
    "F2" => 92.4987,
    "f2" => 87.3071,
    "e2" => 82.4069,
    "D2" => 77.7817,
    "d2" => 73.4162,
    "C2" => 69.2957,
    "c2" => 65.4064,
    "b1" => 61.7354,
    "A1" => 58.2705,
    "a1" => 55.0000,
    "G1" => 51.9131,
    "g1" => 48.9994,
    "F1" => 46.2493,
    "f1" => 43.6535,
    "e1" => 41.2034,
    "D1" => 38.8909,
    "d1" => 36.7081,
    "C1" => 34.6478,
    "c1" => 32.7032,
    "b0" => 30.8677,
    "A0" => 29.1352,
    "a0" => 27.5000
  }

  def from_simple_string(string, note_duration) do
    sequence = string
    |> String.replace(~r/[|\n\t\r ]/, "")
    |> String.replace("-", "--")
    |> String.replace(">", ">>")
    |> sequence_simple_string([])

    %Sequencer{sequence: sequence, note_duration: note_duration}
  end

  defp sequence_simple_string("", sequence), do: Enum.reverse(sequence)
  defp sequence_simple_string(song, sequence) do
    {note, rest} = String.split_at(song, 2)
    decoded_note = decode_note(sequence, note)
    sequence_simple_string(rest, [decoded_note | sequence])
  end

  defp decode_note([{freq, _} | _], "--"), do: {freq, 0.0}
  defp decode_note([], "--"), do: {0.000000001, 0.0}
  defp decode_note([{freq, amp} | _], ">>"), do: {freq, amp}
  defp decode_note(_prev, note), do: {Map.fetch!(@notes, note), 1.0}
end