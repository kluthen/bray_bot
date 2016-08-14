defmodule MapChooserTest do
  use ExUnit.Case

  import BrayBot.MapChooser

  test "chooses 1 map from a list" do
    choices = ["A", "B", "C"] 
    assert Enum.member?(choices, choose_map(choices))
  end

  test "formats a map list into friendly text sorted by abbreviation" do
    hots_maps = %{b: "bar", a: "foo"}
    expected = """
    a: foo
    b: bar
    """

    assert format_maps(hots_maps) == String.trim_trailing(expected)
  end
end
