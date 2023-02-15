defmodule RCE.Users.Manager do
  use GenServer

  alias RCE.Users

  @update_interval 60_1000

  def start_link(opts) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, [], name: name)
  end

  def list_users(server \\ __MODULE__) do
    GenServer.call(server, :list_users)
  end

  ###
  # GenServer behaviour implementation
  ###

  @impl true
  def init([]) do
    schedule_tick()
    {:ok, %{min_number: random_integer(), timestamp: nil}}
  end

  @impl true
  def handle_call(:list_users, _from, state) do
    users = Users.list_users(points: {:gt, state.min_number}, limit: 2)
    {:reply, {users, state.timestamp}, %{state | timestamp: DateTime.utc_now()}}
  end

  @impl true
  def handle_info(:tick, state) do
    schedule_tick()
    Users.refresh_user_points()
    {:noreply, %{state | min_number: random_integer()}}
  end

  ###
  # Utility functions
  ###

  # Generate a new random integer in the range [0, 100]
  defp random_integer, do: :rand.uniform(101) - 1

  defp schedule_tick, do: Process.send_after(self(), :tick, @update_interval)
end
