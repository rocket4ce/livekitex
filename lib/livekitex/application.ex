defmodule Livekitex.Application do
  @moduledoc """
  Application module for Livekitex.
  """

  use Application

  def start(_type, _args) do
    children = [
      {Finch, name: Livekitex.Finch}
    ]

    opts = [strategy: :one_for_one, name: Livekitex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
