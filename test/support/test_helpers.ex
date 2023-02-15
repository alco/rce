defmodule RCE.TestHelpers do
  def start_user_manager!(opts \\ []) do
    opts = Keyword.merge([name: nil, debug_pid: self()], opts)
    {:ok, user_manager} = RCE.Users.Manager.start_link(opts)

    # Make the manager process the default for the current process.
    Process.put(RCE.Users.Manager, user_manager)

    Ecto.Adapters.SQL.Sandbox.allow(RCE.Repo, self(), user_manager)

    user_manager
  end
end
