defmodule RailTest do
  use ExUnit.Case
  use Rail

  doctest Rail

  defmodule Rail2 do
    use Rail

    rail foo(a, b) do
      x = a + b
      y <- negate(a)

      x + y
    end

    rail negate(a) do
      -a
    end
  end

  test "rail/2" do
    assert {:ok, 2} == Rail2.foo(1, 2)
  end

  test "rail/1" do
    result =
      rail do
        x <- {:ok, 1}
        y <- {:ok, 2}

        x + y
      end

    assert {:ok, 3} == result
  end
end
