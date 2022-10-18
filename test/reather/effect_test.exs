defmodule ReatherTest.EffectTest do
  use ExUnit.Case
  use Reather

  defmodule Target do
    reather foo() do
      x <- {:ok, 1}
      send(self(), :reather)

      x + 1
    end
  end

  test "with side effect" do
    assert {:ok, 2} == Target.foo()
    assert_receive(:reather)
  end
end
