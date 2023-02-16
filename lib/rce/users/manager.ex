defmodule RCE.Users.Manager do
  use GenServer

  alias RCE.Users

  require Logger

  @default_update_interval 60_1000

  def start_link(opts) do
    options =
      case Keyword.fetch(opts, :name) do
        {:ok, nil} -> []
        {:ok, name} -> [name: name]
        :error -> [name: __MODULE__]
      end

    init_args = Keyword.drop(opts, [:name])
    GenServer.start_link(__MODULE__, init_args, options)
  end

  def list_users(server \\ default_server()) do
    GenServer.call(server, :list_users)
  end

  if Mix.env() == :test do
    def default_server do
      Process.get(__MODULE__) || __MODULE__
    end
  else
    def default_server, do: __MODULE__
  end

  ###
  # GenServer behaviour implementation
  ###

  @impl true
  def init(opts) do
    update_interval = Keyword.get(opts, :update_interval, @default_update_interval)
    schedule_user_update(update_interval)

    debug_pid = Keyword.get(opts, :debug_pid)

    {:ok,
     %{
       min_number: random_integer(),
       timestamp: nil,
       update_interval: update_interval,
       debug_pid: debug_pid
     }}
  end

  @impl true
  def handle_call(:list_users, _from, state) do
    users = Users.list_users(points: {:gt, state.min_number}, limit: 2)
    # NOTE: the specification for the coding exercise does not specify which time zone
    # to use for timestamps. I'm defaulting to UTC as the more robust, less
    # error-prone choice than using local time.
    {:reply, {users, state.timestamp}, %{state | timestamp: DateTime.utc_now()}}
  end

  @impl true
  def handle_info(:update_users, state) do
    schedule_user_update(state.update_interval)

    case Users.refresh_user_points() do
      {:ok, _} ->
        if state.debug_pid, do: send(state.debug_pid, {:updated_users, self()})

      other ->
        Logger.error("Failed to update users", %{reason: inspect(other)})
    end

    {:noreply, %{state | min_number: random_integer()}}
  end

  ###
  # Utility functions
  ###

  # Generate a new random integer in the range [0, 100]
  defp random_integer, do: :rand.uniform(101) - 1

  defp schedule_user_update(timeout), do: Process.send_after(self(), :update_users, timeout)
end
