defmodule Synthex.Filter.Biquad do
  use Synthex.Math

  alias Synthex.Filter.Biquad

  defstruct [coefficients: {1.0, 0.0, 0.0, 1.0, 0.0, 0.0}, sample: 0.0, in: {0.0, 0.0}, out: {0.0, 0.0}]

  def get_sample(_ctx, state = %Biquad{coefficients: {a0, a1, a2, b0, b1, b2}, sample: sample, in: {i1, i2}, out: {o1, o2}}) do
    output = ((b0/a0) * sample) + ((b1/a0) * i1) + ((b2/a0) * i2) - ((a1/a0) * o1) - ((a2/a0) * o2)
    state = state |> Map.put(:in, {sample, i1}) |> Map.put(:out, {output, o1})

    {state, output}
  end

  defp get_a(db_gain), do: :math.pow(10, (db_gain/40))

  defp get_w0(rate, freq) do
    w0 = @tau * (freq/rate)
    cos_w0 = :math.cos(w0)
    sin_w0 = :math.sin(w0)

    {w0, cos_w0, sin_w0}
  end

  defp get_alpha(:q, _w0, sin_w0, q, _), do: sin_w0 / (2 * q)
  defp get_alpha(:bandwidth, w0, sin_w0, bw, _), do: sin_w0 * :math.sinh((:math.log(2) / 2) * bw * (w0 / sin_w0))
  defp get_alpha(:slope, _w0, sin_w0, s, a), do: (sin_w0 / 2) * :math.sqrt((a + 1 / a) * (1 / s - 1) + 2)

  def lowpass(rate, freq, q) do
    {w0, cos_w0, sin_w0} = get_w0(rate, freq)
    alpha = get_alpha(:q, w0, sin_w0, q, :none)

    a0 = 1 + alpha
    a1 = -2 * cos_w0
    a2 = 1 - alpha
    b1 = 1 - cos_w0
    b0 = b2 = b1 / 2

    %Biquad{coefficients: {a0, a1, a2, b0, b1, b2}}
  end

  def highpass(rate, freq, q) do
    {w0, cos_w0, sin_w0} = get_w0(rate, freq)
    alpha = get_alpha(:q, w0, sin_w0, q, :none)
    one_plus_cos_w0 = (1 + cos_w0)

    a0 = 1 + alpha
    a1 = -2 * cos_w0
    a2 = 1 - alpha
    b0 = b2 = one_plus_cos_w0 / 2
    b1 = -one_plus_cos_w0

    %Biquad{coefficients: {a0, a1, a2, b0, b1, b2}}
  end

  def bandpass_skirt(rate, freq, {type, q_or_bw}) do
    {w0, cos_w0, sin_w0} = get_w0(rate, freq)
    alpha = get_alpha(type, w0, sin_w0, q_or_bw, :none)
    half_sin_w0 = sin_w0 / 2

    a0 = 1 + alpha
    a1 = -2 * cos_w0
    a2 = 1 - alpha
    b0 = half_sin_w0
    b1 = 0.0
    b2 = -half_sin_w0

    %Biquad{coefficients: {a0, a1, a2, b0, b1, b2}}
  end

  def bandpass_peak(rate, freq, {type, q_or_bw}) do
    {w0, cos_w0, sin_w0} = get_w0(rate, freq)
    alpha = get_alpha(type, w0, sin_w0, q_or_bw, :none)

    a0 = 1 + alpha
    a1 = -2 * cos_w0
    a2 = 1 - alpha
    b0 = alpha
    b1 = 0.0
    b2 = -alpha

    %Biquad{coefficients: {a0, a1, a2, b0, b1, b2}}
  end

  def notch(rate, freq, {type, q_or_bw}) do
    {w0, cos_w0, sin_w0} = get_w0(rate, freq)
    alpha = get_alpha(type, w0, sin_w0, q_or_bw, :none)

    a0 = 1 + alpha
    a1 = b1 = -2 * cos_w0
    a2 = 1 - alpha
    b0 = b2 = 1.0

    %Biquad{coefficients: {a0, a1, a2, b0, b1, b2}}
  end

  def allpass(rate, freq, q) do
    {w0, cos_w0, sin_w0} = get_w0(rate, freq)
    alpha = get_alpha(:q, w0, sin_w0, q, :none)

    a0 = b2 = 1 + alpha
    a1 = b1 = -2 * cos_w0
    a2 = b0 = 1 - alpha

    %Biquad{coefficients: {a0, a1, a2, b0, b1, b2}}
  end

  def peaking_eq(rate, freq, db_gain, {type, q_or_bw}) do
    a = get_a(db_gain)
    {w0, cos_w0, sin_w0} = get_w0(rate, freq)
    alpha = get_alpha(type, w0, sin_w0, q_or_bw, :none)
    alpha_on_a = alpha/a
    a_times_alpha = alpha * a

    a0 = 1 + alpha_on_a
    a1 = b1 = -2 * cos_w0
    a2 = 1 - alpha_on_a
    b0 = 1 + a_times_alpha
    b2 = 1 - a_times_alpha

    %Biquad{coefficients: {a0, a1, a2, b0, b1, b2}}
  end

  def lowshelf(rate, freq, db_gain, {type, q_or_slope}) do
    a = get_a(db_gain)
    {w0, cos_w0, sin_w0} = get_w0(rate, freq)
    alpha = get_alpha(type, w0, sin_w0, q_or_slope, a)
    ap1 = a + 1
    am1 = a - 1
    ap1_cos_w0 = ap1 * cos_w0
    am1_cos_w0 = am1 * cos_w0
    beta = 2 * :math.sqrt(a) * alpha

    a0 = ap1 + am1_cos_w0 + beta
    a1 = -2 * (am1 + ap1_cos_w0)
    a2 = ap1 + am1_cos_w0 - beta
    b0 = a * (ap1 - am1_cos_w0 + beta)
    b1 = 2 * a * (am1 - ap1_cos_w0)
    b2 = a * (ap1 - am1_cos_w0 - beta)

    %Biquad{coefficients: {a0, a1, a2, b0, b1, b2}}
  end

  def highshelf(rate, freq, db_gain, {type, q_or_slope}) do
    a = get_a(db_gain)
    {w0, cos_w0, sin_w0} = get_w0(rate, freq)
    alpha = get_alpha(type, w0, sin_w0, q_or_slope, a)
    ap1 = a + 1
    am1 = a - 1
    ap1_cos_w0 = ap1 * cos_w0
    am1_cos_w0 = am1 * cos_w0
    beta = 2 * :math.sqrt(a) * alpha

    a0 = ap1 - am1_cos_w0 + beta
    a1 = 2 * (am1 - ap1_cos_w0)
    a2 = ap1 - am1_cos_w0 - beta
    b0 = a * (ap1 + am1_cos_w0 + beta)
    b1 = -2 * a * (am1 + ap1_cos_w0)
    b2 = a * (ap1 + am1_cos_w0 - beta)

    %Biquad{coefficients: {a0, a1, a2, b0, b1, b2}}
  end

end