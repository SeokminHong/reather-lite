defmodule ReatherTest.RescueTest do
  use ExUnit.Case
  use Rail

  defmodule Target do
    use Rail

    rail div(a, b) do
      x <- div_inner(a, b)

      x
    rescue
      ArithmeticError -> {:error, :div_by_zero}
    end

    def div_inner(a, b) when is_number(a) and is_number(b) do
      if b == 0 do
        raise ArithmeticError
      else
        a / b
      end
    end
  end

  test "Simple rail" do
    assert {:ok, 3} == Target.div(9, 3)
    assert {:error, :div_by_zero} == Target.div(1, 0)
    # Unhandled exception
    assert_raise FunctionClauseError, fn -> Target.div(:ok, :error) end
  end
end
