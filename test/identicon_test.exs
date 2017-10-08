defmodule IdenticonTest do
  use ExUnit.Case
  doctest Identicon

  test "main completes and returns :ok" do
    identicon = Identicon.main("asdf")
    assert identicon == :ok
  end
end
