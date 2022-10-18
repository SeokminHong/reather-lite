defmodule Rail do
  require Rail.Macros

  defmacro __using__([]) do
    quote do
      import Rail.Macros, only: [reather: 1, reather: 2, reatherp: 2]
      require Rail.Macros
      alias Rail.Either
    end
  end
end
