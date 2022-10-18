# Rail

[![test](https://github.com/SeokminHong/rail/actions/workflows/test.yml/badge.svg)](https://github.com/SeokminHong/rail/actions/workflows/test.yml)
[![Coverage Status](https://coveralls.io/repos/github/SeokminHong/rail/badge.svg?branch=main)](https://coveralls.io/github/SeokminHong/rail?branch=main)
[![Hex.pm](https://img.shields.io/hexpm/v/rail)](https://hex.pm/packages/rail)
[![GitHub](https://img.shields.io/github/license/SeokminHong/rail)](https://github.com/SeokminHong/rail/blob/main/LICENSE)

`Rail` is a shortcut of `Reader` + `Either` monads pattern.

It makes you define and unwrap the `Rail` easiliy by using the `rail` macro.

The original idea is from [jechol/rail](https://github.com/jechol/rail), and this is a
lite version without using [Witchcraft](https://witchcrafters.github.io/).

## Installation

```elixir
def deps do
  [
    {:rail, "~> 1.0"}
  ]
end
```

## Usage

### Basic usage

`rail` macro defines a function returns `Rail`.

```elixir
defmodule Target do
  use Rail

  rail foo(a, b) do
    a + b
  end
end

iex> Target.foo(1, 1)
%Rail{...}
```

Since the `Rail` is lazily evaluated, it does nothing until call `Rail.run/2`.

```elixir
iex> Target.foo(1, 1) |> Rail.run()
{:ok, 2}
```

The result of `Rail` is always `{:ok, value}` or `{:error, error}`.

In a `rail` block, the `ok` tuple will be automatically unwrapped by a `<-` operator.

```elixir
defmodule Target do
  use Rail

  rail foo() do
    a <- {:ok, 1}         # a = 1
    {b, c} <- {:ok, 2, 3} # b = 2, c = 3
    d = nil
    ^d <- :ok

    a + b + c
  end
end

iex> Target.foo() |> Rail.run()
{:ok, 6}
```

Also, a `Rail` unwrap into a value with a `<-` operator.

```elixir
defmodule Target do
  use Rail

  rail foo(a, b) do
    x <- bar(a) # The result of bar(a) is {:ok, a + 1} and x will be bound to a + 1.

    x + b
  end

  rail bar(a), do: a + 1
end

iex> Target.foo(1, 1) |> Rail.run()
{:ok, 3}
```

Because of the either monad, when the `<-` operator meets an error tuple,
the rail will return it immediately.

```elixir
defmodule Target do
  use Rail

  rail foo() do
    x <- {:ok, 1}
    y <- {:error, "asdf", 1} # foo will return {:error, {"asdf", 1}}

    x + y
  end
end

iex> Target.foo() |> Rail.run()
{:error, {"asdf", 1}}
```

### Inline `rail`

`rail` also can be inlined.

```elixir
iex> r =
...>   rail do
...>     x <- {:ok, 1}
...>     y <- {:ok, 2}
...>
...>     x + y
...>   end
%Rail{...}

iex> r |> Rail.run()
{:ok, 3}
```

### `else`, `rescue`, `catch`, `after`

`rail` macro also accepts above clauses.

```elixir
defmodule Target do
  use Rail

  rail foo(a, b) do
    x <- bar(a)
    y <- baz(b)

    x + y
  else
    {:error, _} -> {:ok, a + b}
    ok -> ok
  rescue
    ArithmeticError -> {:error, :div_by_zero}
  after
    IO.puts("Target.foo/2")
  end
end
```

### `railp`

If you want to define a private rail, use `railp` macro instead.

```elixir
defmodule Target do
  use Rail

  railp foo() do
    1
  end
end
```

### `Rail.map`

You can `map` a function to a `Rail`.
The given function will be applied lazily when the result of
the rail is an `ok` tuple.

```elixir
defmodule Target do
  use Rail

  rail foo() do
    x <- {:ok, 1}

    x
  end

  rail bar() do
    x <- {:error, 1}

    x
  end
end

iex> Target.foo()
...> |> Rail.map(fn x -> x + 1 end)
...> |> Rail.run()
{:ok, 2}

iex> Target.bar()
...> |> Rail.map(fn x -> x + 1 end)
...> |> Rail.run()
{:error, 1}
```

### `Rail.traverse`

Transform a list of reathers to an rail of a list.

This operation is lazy, so it's never computed until
explicitly call `Rail.run/2`.

```elixir
iex> r = [{:ok, 1}, {:ok, 2}, {:ok, 3}]
...>     |> Enum.map(&Rail.of/1) # Make reathers return each elements.
...>     |> Rail.traverse()
iex> Rail.run(r)
{:ok, [1, 2, 3]}

iex> r = [{:ok, 1}, {:error, "error"}, {:ok, 3}]
...>     |> Enum.map(&Rail.of/1) # Make reathers return each elements.
...>     |> Rail.traverse()
iex> Rail.run(r)
{:error, "error"}
```

### `Either.new`

Convert a value into `ok` or `error` tuple. The result is a tuple having
an `:ok` or `:error` atom for the first element, and a value for the second
element.

### `Either.error`

Make an error tuple from a value.

### `Either.map`

`map` a function to an either tuple.
The given function will be applied lazily
when the either is an `ok` tuple.

### `Either.traverse`

Transform a list of eithers to an either of a list.
If any of the eithers is `error`, the result is `error`.

```elixir
iex> [{:ok, 1}, {:ok, 2}] |> Either.traverse()
{:ok, [1, 2]}
iex> [{:ok, 1}, {:error, "error!"}, {:ok, 2}]
...> |> Either.traverse()
{:error, "error!"}
```

## LICENSE

[MIT](./LICENSE)
