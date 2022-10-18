defmodule ReatherTest.ExceptionTest do
  use ExUnit.Case
  use Reather

  defmodule Target do
    use Reather

    def case_exception() do
      x = "test"

      case x do
        "" -> :empty
      end
    end

    reather foo() do
      x <- case_exception()

      x
    end

    reather bar() do
      "test"
    else
      {:ok, ""} -> :empty
    end

    def try_exception() do
      x = "test"

      try do
        x
      else
        "" -> :empty
      after
      end
    end

    reather baz() do
      x <- try_exception()

      x
    end

    reather qux() do
      "test"
    else
      {:ok, ""} -> :empty
    after
    end
  end

  test "with else clause" do
    assert_raise CaseClauseError,
                 "no case clause matching: \"test\"",
                 fn ->
                   Target.foo()
                 end
  end

  test "with try clause" do
    assert_raise TryClauseError,
                 "no try clause matching: \"test\"",
                 fn -> Target.baz() end
  end
end
