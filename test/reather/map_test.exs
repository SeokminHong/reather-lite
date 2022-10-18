defmodule ReatherTest.MapTest do
  use ExUnit.Case
  use Reather

  test "either map" do
    assert {:error, 1} == Either.error(1) |> Either.map(fn x -> x + 1 end)
    assert {:ok, 2} == Either.new(1) |> Either.map(fn x -> x + 1 end)
  end
end
