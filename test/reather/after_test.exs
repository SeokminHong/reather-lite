defmodule ReatherTest.AfterTest do
  use ExUnit.Case
  use Reather

  defmodule Target do
    use Reather

    reather foo(a, b) do
      x <- bar(a, b)

      x
    else
      {:error, :div_by_zero} -> {:ok, :nan}
      other -> other
    after
      send(self(), :after)
    end

    def bar(a, b) do
      if b == 0 do
        {:error, :div_by_zero}
      else
        a / b
      end
    end
  end

  test "Simple reather" do
    assert {:ok, 0.5} == Target.foo(1, 2)
    assert_receive :after

    assert {:ok, :nan} == Target.foo(1, 0)
    assert_receive :after
  end
end
