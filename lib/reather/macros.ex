defmodule Reather.Macros do
  alias Reather.Either

  @doc """
  Declare a reather.
  """
  defmacro reather(head, body) do
    expanded_body = expand_body(body)

    quote do
      with {line, doc} when is_bitstring(doc) <- Module.get_attribute(__MODULE__, :doc) do
        Module.put_attribute(
          __MODULE__,
          :doc,
          Reather.Macros.decorate_doc({line, doc})
        )
      end

      def unquote(head), unquote(expanded_body)
    end
  end

  defmacro reather([do: _] = body) do
    expand_body(body)
  end

  defp expand_body([{:do, do_block} | rest]) do
    [{:do, expand_do_block(do_block)} | rest]
  end

  @doc """
  Declare a private reather.
  """
  defmacro reatherp(head, body) do
    expanded_body = expand_body(body)

    quote do
      defp unquote(head), unquote(expanded_body)
    end
  end

  defp expand_do_block({:__block__, _ctx, exprs}) do
    parse_exprs(exprs)
  end

  defp expand_do_block(expr) do
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
