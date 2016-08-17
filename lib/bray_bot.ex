defmodule BrayBot do
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

  # Select command to execute based off of message payload
  defp _command_parser(payload, state) do
    case MessageHelper.msg_command_parse(payload) do
      {nil, msg} -> 
        Logger.info("do nothing for message: #{msg}")
      {cmd, msg} -> 
        _execute_command({cmd, msg}, payload, state)
    end
  end

  defp _execute_command({"bb:echo", message}, payload, state) do
    msg = String.upcase(message)
    Channel.send_message(state[:rest_client], payload.data["channel_id"], %{content: "#{msg} \nbat at ya"})
  end

  defp _execute_command({"bb:ping", _message}, payload, state) do
    Channel.send_message(state[:rest_client], payload.data["channel_id"], %{content: "Pong!"})
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
    cheat_sheet = BrayBot.BattlegroundChooser.all_hots_maps |> BrayBot.BattlegroundChooser.format_maps

    Channel.send_message(state[:rest_client], payload.data["channel_id"], %{content: _code_sample_markdown(cheat_sheet)})
  end

  defp _execute_command({cmd, msg}, _payload, _state) do
    Logger.info("Ignoring command: #{cmd}, msg: #{msg}")
  end


  defp _code_sample_markdown(s) do
    "```\n#{s}\n```"
  end
end
