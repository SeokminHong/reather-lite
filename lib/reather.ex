defmodule Reather do
  require Reather.Macros

  defmacro __using__([]) do
    quote do
      import Reather.Macros, only: [reather: 1, reather: 2, reatherp: 2]
      require Reather.Macros
      alias Reather.Either
    end
  end
end
