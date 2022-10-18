defmodule Rail do
  require Rail.Macros

  defmacro __using__([]) do
    quote do
      import Rail.Macros, only: [rail: 1, rail: 2, railp: 2]
      require Rail.Macros
      alias Rail.Either
    end
  end
end
