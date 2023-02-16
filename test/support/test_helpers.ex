defmodule RCE.TestHelpers do
  def start_user_manager!(opts \\ []) do
    opts = Keyword.merge([name: nil, update_interval: 5_000, debug_pid: self()], opts)

    {:ok, user_manager} = RCE.Users.Manager.start_link(opts)
    RCE.Users.Manager.put_default_server(user_manager)
    Ecto.Adapters.SQL.Sandbox.allow(RCE.Repo, self(), user_manager)
    user_manager
  end

  def user_points_map(users), do: Map.new(users, fn user -> {user.id, user.points} end)
end
