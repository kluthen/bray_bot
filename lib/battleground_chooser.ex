defmodule BrayBot.BattlegroundChooser do

  def start_link do
    Agent.start_link(fn -> all_battlegrounds end, name: __MODULE__)
  end

  def ban(key), do: ban(__MODULE__, key) 
  def ban(bg_chooser, key) do
    Agent.get_and_update(bg_chooser, &Map.pop(&1, key))
  end

  def list(bg_chooser) do
    Agent.get(bg_chooser, &(&1))
  end

  def reset(), do: reset(__MODULE__)
  def reset(bg_chooser) do
    Agent.update(bg_chooser, fn _ -> all_battlegrounds end)
  end

  def all_battlegrounds do
    %{
      "tod"   => "Towers of Doom",
      "is"    => "Infernal Shrines",
      "boe"   => "Battlefield of Eternity",
      "totsq" => "Tomb of the Spider Queen",
      "st"    => "Sky Temple",
      "got"   => "Garden of Terror",
      "bb"    => "Blackheart's Bay",
      "ds"    => "Dragon Shire",
      "ch"    => "Cursed Hollow"
    }
  end

  @doc """
  Chooses one entry from a map of battlegrounds.

    iex> bgs = %{foo: "Foo", bar: "Bar"}
    ...> Enum.member?(bgs, BrayBot.BattlegroundChooser.choose_battleground(bgs))
    true

  """
  def choose_battleground(bg_choices) do
    Enum.random(bg_choices)
  end

  @doc ~S"""
  Takes a map of battlegrounds and formats it into a string that lists the
  abbreviations and full names, one battleground per line. The battlegrounds
  are sorted by their abbreviations.

    iex> BrayBot.BattlegroundChooser.format_battlegrounds(%{b: "B", a: "A", c: "C"}) 
    "a: A\nb: B\nc: C"

  """
  def format_battlegrounds(bgs) do
    bgs
    |> Map.to_list 
    |> Enum.sort(fn({a, _}, {b, _}) -> a <= b end) 
    |> Enum.map(fn({nick, name}) -> "#{nick}: #{name}" end) 
    |> Enum.join("\n")
  end

end
