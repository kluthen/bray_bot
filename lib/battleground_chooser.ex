defmodule BrayBot.BattlegroundChooser do

  def start_link do
    Agent.start_link(fn -> all_battlegrounds end, name: __MODULE__)
  end

  def all_battlegrounds do
    %{
      "hm"    => "Haunted Mines",
      "tod"   => "Towers of Doom",
      "is"    => "Infernal Shrines",
      "boe"   => "Battlefield of Eternity",
      "totsq" => "Tomb of the Spider Queen",
      "st"    => "Sky Temple",
      "got"   => "Garden of Terror",
      "bb"    => "Blackheart's Bay",
      "ds"    => "Dragon Shire",
      "ch"    => "Cursed Hollow",
      "bh"    => "Braxis Holdout",
      "wj"    => "Warhead Junction",
      "han"   => "Hanamura"
    }
  end

  def ban(name), do: ban(__MODULE__, name)
  def ban(bg_chooser, name) do
    key = find_bg_key(name)
    Agent.get_and_update(bg_chooser, &Map.pop(&1, key))
  end

  def find_bg_key(name) do
    if Map.has_key?(all_battlegrounds, name) do
      key = name
    else
      fish_key_from_bg_names(name)
    end
  end

  def fish_key_from_bg_names(name) do
    downcased_name = name |> String.downcase
    if entry = all_battlegrounds |> Enum.find(fn {k,v} -> v |> String.downcase |> String.starts_with?(downcased_name) end) do
      entry |> elem(0)
    else
      nil
    end
  end

  def list, do: list(__MODULE__)
  def list(bg_chooser) do
    Agent.get(bg_chooser, &(&1))
  end

  def reset(), do: reset(__MODULE__)
  def reset(bg_chooser) do
    Agent.update(bg_chooser, fn _ -> all_battlegrounds end)
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
