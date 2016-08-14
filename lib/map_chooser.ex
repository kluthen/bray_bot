defmodule BrayBot.MapChooser do

  def all_hots_maps do
    %{
      tod:   "Towers of Doom",
      is:    "Infernal Shrines",
      boe:   "Battlefield of Eternity",
      totsq: "Tomb of the Spider Queen",
      st:    "Sky Temple",
      got:   "Garden of Terror",
      bb:    "Blackheart's Bay",
      ds:    "Dragon Shire",
      ch:    "Cursed Hollow"
    }
  end

  def choose_map(map_choices) do
    Enum.random(map_choices)
  end

  def format_maps(maps) do
    maps
    |> Map.to_list 
    |> Enum.sort(fn({a, _}, {b, _}) -> a <= b end) 
    |> Enum.map(fn({nick, name}) -> "#{nick}: #{name}" end) 
    |> Enum.join("\n")
  end

end
