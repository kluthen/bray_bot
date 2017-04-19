defmodule BrayBot.EventHandlers do

  @moduledoc """
  Start off with a simple echo


  "!bb:echo foo" or "!bb:ping"
  """

  require Logger

  alias DiscordEx.Client.Helpers.MessageHelper
  alias DiscordEx.RestClient.Resources.Channel

  def handle_event({:message_create, payload}, state) do
    spawn fn ->
      _command_parser(payload, state)
    end
    {:ok, state}
  end

  # Fallback handler
  def handle_event({event, _payload}, state) do
    Logger.info "Received Event: #{event}"
    {:ok, state}
  end

  defp command_came_from_bray_bot(payload) do
    payload[:data]["author"]["username"] == "BrayBot"
  end

  # Select command to execute based off of message payload
  defp _command_parser(payload, state) do
    if command_came_from_bray_bot(payload) do
      IO.puts "Prevent BrayBot from sending commands to itself"
    else
      case MessageHelper.msg_command_parse(payload) do
        {nil, msg} ->
          Logger.info("do nothing for message: #{msg}")
        {cmd, msg} ->
          _execute_command({cmd, msg}, payload, state)
      end
    end
  end

  defp _execute_command({"bb:ack", _message}, payload, state) do
    bill = """
    _   /|
    \\'o.O'
    =(___)=
       U
    """
    Channel.send_message(state[:rest_client], payload.data["channel_id"], %{content: _code_sample_markdown(bill)})
  end

  defp _execute_command({"bb:help", _message}, payload, state) do
    Channel.send_message(state[:rest_client], payload.data["channel_id"], %{content: _help})
  end

  defp _execute_command({"bb:list", _message}, payload, state) do
    Channel.send_message(state[:rest_client],
                         payload.data["channel_id"],
                         %{content: _code_sample_markdown(_formatted_remaining_bgs)})
  end

  defp _execute_command({"bb:ban", key}, payload, state) do
    all_bgs = BrayBot.BattlegroundChooser.all_battlegrounds

    if BattlegroundChooser.find_bg_key(key) do
      BrayBot.BattlegroundChooser.ban(key)
      output = "Banned `'#{Map.get(all_bgs, key)}'`\n\n" <> _code_sample_markdown(_formatted_remaining_bgs)

      Channel.send_message(state[:rest_client], payload.data["channel_id"], %{content: output})
    else
      Channel.send_message(state[:rest_client], payload.data["channel_id"], %{content: "'#{key}' is not a valid abbreviation"})
    end
  end

  defp _execute_command({"bb:reset", _message}, payload, state) do
    BrayBot.BattlegroundChooser.reset()

    Channel.send_message(state[:rest_client], payload.data["channel_id"], %{content: "Bans removed"})
  end

  defp _execute_command({"bb:random", _message}, payload, state) do
    output =
      if Enum.empty?(BrayBot.BattlegroundChooser.list) do
        """
        You banned everything. No map for you!
        Use `!bb:reset` to start over.
        """
      else
        BrayBot.BattlegroundChooser.list
          |> BrayBot.BattlegroundChooser.choose_battleground
          |> elem(1)
          |> _code_sample_markdown
      end

    Channel.send_message(state[:rest_client], payload.data["channel_id"], %{content: output})
  end

  defp _execute_command({cmd, msg}, _payload, _state) do
    Logger.info("Ignoring command: #{cmd}, msg: #{msg}")
  end


  defp _code_sample_markdown(s) do
    "```\n#{s}\n```"
  end

  defp _formatted_remaining_bgs do
    bgs = BrayBot.BattlegroundChooser.list
    |> BrayBot.BattlegroundChooser.format_battlegrounds

    "Remaining Battlegrounds\n\n" <> bgs
  end


  defp _help do
    """
    Battleground Randomizer

    These commands let you (optionally) ban battlegrounds and then choose one at random.

      `!bb:reset` - Removes all bans

      `!bb:list`  - Shows unbanned battlegrounds (and their abbreviations)

      `!bb:ban abbreviation` - ban a battlegound

        Ex: Banning Garden of Terror
        `!bb:ban got`

      `!bb:random` - Choose a random, unbanned, battleground
    """
  end
end
