defmodule ReatherTest.LazyTest do
  use ExUnit.Case
  use Reather
  import ExUnit.CaptureIO

  defmodule Target do
    use Reather

    reather single() do
      (1 + 1) |> IO.inspect()
    end
  end

  test "inspect doesn't run until call Reather.run" do
    assert {{:ok, 2}, "2\n"} = with_io(fn -> Target.single() end)
  end
end
