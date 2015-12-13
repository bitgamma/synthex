defmodule Synthex.Math do
  defmacro __using__(_) do
    quote do
      import Synthex.Math
      @pi :math.pi()
      @tau @pi * 2
      @one_on_pi 1/@pi
      @two_on_pi 2/@pi
    end
  end

  defmacro fmod(val, divider) do
    quote do
      unquote(val) - (Float.floor(unquote(val)/unquote(divider)) * unquote(divider))
    end
  end

  defmacro amplitude_to_frequency(magnitude, min, max) do
    quote do
      (unquote(magnitude) + 1.0) * ((unquote(max) - unquote(min))/2.0) + unquote(min)
    end
  end

  defmacro amplitude_to_rounded_frequency(magnitude, min, max) do
    quote do
      round(unquote(__MODULE__).amplitude_to_frequency(unquote(magnitude), unquote(min), unquote(max)))
    end
  end

  defmacro duration_in_secs_to_sample_count(duration, rate) do
    quote do
      if is_float(unquote(duration)) do
        Float.ceil(unquote(duration) * unquote(rate)) |> trunc
      else
        unquote(duration) * unquote(rate)
      end
    end
  end

  defmacro duty_cycle_to_radians(duty_cycle) do
    quote do
      @tau * unquote(duty_cycle)
    end
  end

  defmacro shift_by(sample, amount) do
    quote do
      clamp(unquote(sample) + unquote(amount))
    end
  end

  def clamp(sample) when sample <= -1.0, do: -1.0
  def clamp(sample) when sample >= 1.0, do: 1.0
  def clamp(sample), do: sample
end