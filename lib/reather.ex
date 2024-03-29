defmodule Reather do
  defstruct [:reather]

  @type reather :: %Reather{reather: fun()}

  require Reather.Macros
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
      import Kernel, except: [def: 2, defp: 2]
      import Reather.Macros, only: [reather: 1, def: 2, defp: 2]
      require Reather.Macros
      alias Reather.Either
    end
  end

  @doc """
  Get the current environment.
  """
  @spec ask :: reather
  def ask(), do: Reather.new(fn env -> {:ok, env} end)

  @doc """
  Run the reather.
  """
  @spec run(reather, %{}) :: any
  def run(%Reather{reather: fun}, env \\ %{}) do
    fun.(env)
  end

  @doc """
  Map a function to the reather.

  `map` is lazy, so it's never computed until explicitly call
  `Reather.run/2`.

  ## Examples
      iex> r = reather do
      ...>       x <- {:ok, 1}
      ...>       x
      ...>     end
      iex> r
      ...> |> Reather.map(fn x -> x + 1 end)
      ...> |> Reather.run()
      {:ok, 2}
  """
  @spec map(reather, (any -> any)) :: reather
  def map(r, fun) do
    Reather.Macros.reather do
      x <- r

      fun.(x)
    end
  end

  @doc """
  Transform a list of reathers to an reather of a list.

  This operation is lazy, so it's never computed until
  explicitly call `Reather.run/2`.

  ## Examples
      iex> r = [{:ok, 1}, {:ok, 2}, {:ok, 3}]
      ...>     |> Enum.map(&Reather.of/1)
      ...>     |> Reather.traverse()
      iex> Reather.run(r)
      {:ok, [1, 2, 3]}

      iex> r = [{:ok, 1}, {:error, "error"}, {:ok, 3}]
      ...>     |> Enum.map(&Reather.of/1)
      ...>     |> Reather.traverse()
      iex> Reather.run(r)
      {:error, "error"}
  """
  @spec traverse([reather]) :: reather
  def traverse(traversable) when is_list(traversable) do
    Reather.new(fn env ->
      traversable
      |> Enum.map(fn %Reather{} = r ->
        Reather.run(r, env)
      end)
      |> Either.traverse()
    end)
  end

  @doc """
  Inspect the reather result when run.
  """
  @spec inspect(reather, keyword) :: reather
  def inspect(%Reather{} = r, opts \\ []) do
    Reather.new(fn env ->
      r |> Reather.run(env) |> IO.inspect(opts)
    end)
  end

  @doc """
  Create a new `Reather` from the function.
  """
  @spec new(fun) :: reather
  def new(fun), do: %Reather{reather: fun}

  @doc """
  Create a `Reather` from the value.
  """
  @spec of(any) :: reather
  def of(v), do: Reather.new(fn _ -> Either.new(v) end)

  @doc """
  Create a `Reather` from the value.
  If the value is `Reather`, it will be returned as is.

  ## Examples
      iex> %Reather{} = Reather.wrap(:ok)

      iex> r = %Reather{}
      iex> ^r = Reather.wrap(r)
  """
  @spec wrap(any) :: reather
  def wrap(%Reather{} = r), do: r
  def wrap(v), do: of(v)

  @doc """
  Create a new `Reather` from a reather and function.
  The function will be called after the reather is run.
  """
  @spec chain(reather, (any -> reather)) :: reather
  def chain(%Reather{} = rhs, chain_fun) when is_function(chain_fun, 1) do
    Reather.new(fn env ->
      rhs
      |> Reather.run(env)
      |> case do
        {:ok, value} ->
          chain_fun.(value) |> Reather.run(env)

        {:error, _} = error ->
          error
      end
    end)
  end
end
