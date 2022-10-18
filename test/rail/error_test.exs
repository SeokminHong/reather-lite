defmodule RailTest.ErrorTest do
  use ExUnit.Case
  use Rail

  defmodule Target do
    use Rail

    rail foo() do
      x <- {:ok, 1}
      y <- {:error, "wrong", 1}

      x + y
    end
  end

  test "returns error" do
    assert {:error, {"wrong", 1}} == Target.foo()
  end
end
