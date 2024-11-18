defmodule RiderTest do
  use ExUnit.Case
  doctest Rider

  test "greets the world" do
    assert Rider.hello() == :world
  end
end
