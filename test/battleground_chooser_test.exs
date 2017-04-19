defmodule BattlegroundChooserTest do
  use ExUnit.Case, async: false

  doctest BrayBot.BattlegroundChooser

  setup do
    BrayBot.BattlegroundChooser.reset(BrayBot.BattlegroundChooser)
    {:ok, chooser: BrayBot.BattlegroundChooser}
  end

  test "defaults to the full list of battlegrounds", %{chooser: chooser} do
    assert BrayBot.BattlegroundChooser.list(chooser) == BrayBot.BattlegroundChooser.all_battlegrounds
  end

  test "ban a battleground from the available pool", %{chooser: chooser} do
    assert Map.has_key?(BrayBot.BattlegroundChooser.list(chooser), "is")

    BrayBot.BattlegroundChooser.ban(chooser, "is")
    refute Map.has_key?(BrayBot.BattlegroundChooser.list(chooser), "is")
  end

  test "ban a battleground via the first few letters of its name (case insensitve)", %{chooser: chooser} do
    assert Map.has_key?(BrayBot.BattlegroundChooser.list(chooser), "is")

    BrayBot.BattlegroundChooser.ban(chooser, "inf")
    refute Map.has_key?(BrayBot.BattlegroundChooser.list(chooser), "is")
  end

  test "`reset` puts all of the battlegrounds back into the pool", %{chooser: chooser} do
    BrayBot.BattlegroundChooser.ban(chooser, "is")
    BrayBot.BattlegroundChooser.ban(chooser, "tod")
    refute Map.has_key?(BrayBot.BattlegroundChooser.list(chooser), "is")
    refute Map.has_key?(BrayBot.BattlegroundChooser.list(chooser), "tod")

    BrayBot.BattlegroundChooser.reset(chooser)
    assert Map.has_key?(BrayBot.BattlegroundChooser.list(chooser), "is")
    assert Map.has_key?(BrayBot.BattlegroundChooser.list(chooser), "tod")
  end

  test "crashing the process results in a shiny fresh list", %{chooser: chooser} do
    BrayBot.BattlegroundChooser.ban(chooser, "is")
    BrayBot.BattlegroundChooser.ban(chooser, "tod")
    refute Map.has_key?(BrayBot.BattlegroundChooser.list(chooser), "is")
    refute Map.has_key?(BrayBot.BattlegroundChooser.list(chooser), "tod")

    # Kill off the chooser process, and then wait for it to actually die.
    pid = Process.whereis(chooser)
    ref = Process.monitor(pid)

    Process.exit(pid, :shutdown)
    Process.sleep(200)
    assert_receive {:DOWN, ^ref, _,_,_}

    assert Map.has_key?(BrayBot.BattlegroundChooser.list(chooser), "is")
    assert Map.has_key?(BrayBot.BattlegroundChooser.list(chooser), "tod")
  end
end
