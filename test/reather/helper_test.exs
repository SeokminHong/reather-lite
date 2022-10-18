defmodule ReatherTest.HelperTest do
  use ExUnit.Case
  use Reather
  import ExUnit.CaptureIO

  defmodule Target do
    use Reather

    reather foo(a, b) do
      x = a + b
      y <- bar(a)

      x + y
    end

    reather bar(a) do
      -a
    end

    reather baz(a), do: a + 1
  end

  test "Simple reather" do
    assert {:ok, 2} == Target.foo(1, 2)
  end
end
