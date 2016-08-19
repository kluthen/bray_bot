defmodule BrayBot.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    tok = Application.get_env(:bray_bot, :discord_token)
    children = [
      worker(DiscordEx.Client, [%{token: tok, handler: BrayBot.EventHandlers}]),
      worker(BrayBot.BattlegroundChooser, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
