defmodule Reather do
  defstruct [:reather]

  @type reather :: %Reather{reather: fun()}

  require Reather.Macros
  import Reather.Macros
  alias Reather.Either

  @moduledoc """
  Reather is the combined form of Reader and Either monad.
  A `Reather` wrapps an environment and the child functions can
  use the environment to access the values.

  The evaluation of `Reather` is lazy, so it's never computed until
  explicitly call `Reather.run/2`.
  """

  defmacro __using__([]) do
    quote do
      import Reather.Macros, only: [reather: 1, reather: 2, reatherp: 2]
      require Reather.Macros
      alias Reather.Either
    end
  end

  # @doc """
  # Map a function to the reather.

  # `map` is lazy, so it's never computed until explicitly call
  # `Reather.run/2`.

  # ## Examples
  #     iex> r = reather do
  #     ...>       x <- {:ok, 1}
  #     ...>       x
  #     ...>     end
  #     iex> r
  #     ...> |> Reather.map(fn x -> x + 1 end)
  #     ...> |> Reather.run()
  #     {:ok, 2}
  # """
  # @spec map(reather, (any -> any)) :: reather
  # def map(r, fun) do
  #   reather do
  #     x <- r

  #     fun.(x)
  #   end
  # end

  # @doc """
  # Create a new `Reather` from a reather and function.
  # The function will be called after the reather is run.
  # """
  # @spec chain(reather, (any -> reather)) :: reather
  # def chain(rhs, chain_fun) when is_function(chain_fun, 1) do
  #   rhs
  #   |> Either.new()
  #   |> case do
  #     {:ok, value} ->
  #       chain_fun.(value)

  #     {:error, _} = error ->
  #       error
  #   end
  # end
end
