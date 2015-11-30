defmodule Synthex.Math do
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