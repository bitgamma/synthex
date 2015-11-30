defmodule Synthex.Math do
  defmacro fmod(val, divider) do
    quote do
      unquote(val) - (Float.floor(unquote(val)/unquote(divider)) * unquote(divider))
    end
  end
end