defmodule ReatherTest.AfterTest do
  use ExUnit.Case
  use Reather

  defmodule Target do
    use Reather

    reather foo(a, b) do
      x <- bar(a, b)

      x
    else
      {:error, "same"} -> {:ok, 2 * a}
      other -> other
    after
      send(self(), :after)
    end

    def bar(a, b) do
      if a == b do
        {:error, "same"}
      else
        a + b
      end
    end
  end

  test "Simple reather" do
    assert {:ok, 3} == Target.foo(1, 2)
    assert_receive :after

    assert {:ok, 4} == Target.foo(2, 2)
    assert_receive :after
  end
end
