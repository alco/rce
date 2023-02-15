# Stop the global users manager so that it does not interfere with local manager
# processes that get started in individual tests.
:ok = GenServer.stop(RCE.Users.Manager)

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(RCE.Repo, :manual)
