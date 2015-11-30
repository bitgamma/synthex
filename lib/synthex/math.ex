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
end