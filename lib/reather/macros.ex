defmodule Reather.Macros do
  alias Reather.Either

  @doc """
  Declare a reather.
  """
  defmacro reather(head, body) do
    built_body = build_body(body)

    q =
      quote do
        with {line, doc} when is_bitstring(doc) <- Module.get_attribute(__MODULE__, :doc) do
          Module.put_attribute(
            __MODULE__,
            :doc,
            Reather.Macros.decorate_doc({line, doc})
          )
        end

        def unquote(head) do
          unquote(built_body)
        end
      end

    q |> Macro.to_string() |> IO.puts()

    q
  end

  defmacro reather(body) do
    build_body(body)
  end

  defp build_body([{:do, do_block} | rest]) do
    built_do_block = build_do_block(do_block)

    case rest do
      [] ->
        # no need to wrap
        [do: built_do_block]

      [else: matches] ->
        # wrap with case
        quote do
          case unquote(built_do_block) do
            unquote(matches)
          end
        end

      rest ->
        # Elixir function body is implicit try.
        # So we need to wrap the body with try to support do, else, rescue, catch and after.
        {:try, [], [[do: built_do_block] ++ rest]}
    end
  end

  @doc """
  Declare a private reather.
  """
  defmacro reatherp(head, body) do
    built_body = build_body(body)

    quote do
      defp unquote(head) do
        unquote(built_body)
      end
    end
  end

  defp build_do_block({:__block__, _ctx, exprs}) do
    parse_exprs(exprs)
  end

  defp build_do_block(expr) do
    parse_exprs([expr])
  end

  defp parse_exprs(exprs) do
    {body, ret} = Enum.split(exprs, -1)

    wrapped_ret =
      quote do
        unquote(List.first(ret)) |> Either.new()
      end

    body
    |> List.foldr(wrapped_ret, fn
      {:<-, _ctx, [lhs, rhs]}, acc ->
        quote do
          unquote(rhs) |> Either.chain(fn unquote(lhs) -> unquote(acc) end)
        end

      expr, acc ->
        quote do
          unquote(expr)
          unquote(acc)
        end
    end)
  end

  def decorate_doc({line, doc}) do
    {line, "### (Reather)\n\n" <> doc}
  end
end
