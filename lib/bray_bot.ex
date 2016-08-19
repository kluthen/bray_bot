defmodule BrayBot do
  use Application

  def start(_type, _args) do
    BrayBot.Supervisor.start_link
  end

end
