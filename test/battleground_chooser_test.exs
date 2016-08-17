defmodule BattlegroundChooserTest do
  use ExUnit.Case, async: true
  
  doctest BrayBot.BattlegroundChooser

  setup do
    {:ok, chooser} = BrayBot.BattlegroundChooser.start_link
    {:ok, chooser: chooser}
  end

  test "defaults to the full list of battlegrounds", %{chooser: chooser} do
    assert BrayBot.BattlegroundChooser.list(chooser) == BrayBot.BattlegroundChooser.all_battlegrounds
  end

  test "ban a battleground from the available pool", %{chooser: chooser} do
    assert Map.has_key?(BrayBot.BattlegroundChooser.list(chooser), :is)

    BrayBot.BattlegroundChooser.ban(chooser, :is)
    refute Map.has_key?(BrayBot.BattlegroundChooser.list(chooser), :is)
  end

  test "`reset` puts all of the battlegrounds back into the pool", %{chooser: chooser} do
    BrayBot.BattlegroundChooser.ban(chooser, :is)
    BrayBot.BattlegroundChooser.ban(chooser, :tod)
    refute Map.has_key?(BrayBot.BattlegroundChooser.list(chooser), :is)
    refute Map.has_key?(BrayBot.BattlegroundChooser.list(chooser), :tod)

    BrayBot.BattlegroundChooser.reset(chooser)
    assert Map.has_key?(BrayBot.BattlegroundChooser.list(chooser), :is)
    assert Map.has_key?(BrayBot.BattlegroundChooser.list(chooser), :tod)
  end
end
