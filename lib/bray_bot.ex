defmodule BrayBot do
  @moduledoc """
  Start off with a simple echo


  "!bb:echo foo" or "!bb:ping"
  """

  require Logger

  alias DiscordEx.Client.Helpers.MessageHelper
  alias DiscordEx.RestClient.Resources.Channel

  
  # Message Handler
  #def handle_event({:message_create, payload}, state) do 
    #spawn fn ->
      #if MessageHelper.actionable_message_for?("BrayBot", payload, state) do
        #_command_parser(payload, state)
      #end
    #end
    #{:ok, state}
  #end

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
    Channel.send_message(state[:rest_client], payload.data["channel_id"], %{content: "#{msg} bat at ya"})
  end

  defp _execute_command({"bb:ping", _message}, payload, state) do
    Channel.send_message(state[:rest_client], payload.data["channel_id"], %{content: "Pong!"})
  end

  defp _execute_command({cmd, msg}, _payload, _state) do
    Logger.info("Ignoring command: #{cmd}, msg: #{msg}")
  end

end
