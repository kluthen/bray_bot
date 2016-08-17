defmodule BattlegroundChooserTest do
  use ExUnit.Case

  import BrayBot.BattlegroundChooser

  test "chooses 1 map from a list" do
    choices = ["A", "B", "C"] 
    assert Enum.member?(choices, choose_battleground(choices))
  end

  test "formats a map list into friendly text sorted by abbreviation" do
    hots_bgs = %{b: "bar", a: "foo"}
    expected = """
    a: foo
    b: bar
    """

    assert format_battlegrounds(hots_bgs) == String.trim_trailing(expected)
  end
end
