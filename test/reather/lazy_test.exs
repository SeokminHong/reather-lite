defmodule ReatherTest.LazyTest do
  use ExUnit.Case
  use Reather
  import ExUnit.CaptureIO

  defmodule Target do
    use Reather

    @reather true
    def single() do
      (1 + 1) |> IO.inspect()
    end
  end

  test "inspect doesn't run until call Reather.run" do
    assert {%Reather{}, ""} =
             with_io(fn ->
               Target.single()
             end)

    assert with_io(fn ->
             Target.single() |> Reather.run(%{})
           end) == {{:ok, 2}, "2\n"}
  end
end
