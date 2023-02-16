defmodule RCE.Users.Manager do
  @moduledoc """
  A gen server that periodically updates user points and supports querying of
  user records in a special way.
  """

  use GenServer

  alias RCE.Users

  require Logger

  @doc """
  Start the gen server process.

  ## Options

    - `name: <atom>` - which local name to register the process under. Pass
      `nil` to forego the registration entirely. Default: #{__MODULE__}.

    - `update_interval: <integer>` (required) - how often user points should be
      updated, in milliseconds.

    - `debug_pid: <pid>` - optional PID to send debug messages to. Should not be
      used in production.
  """
  @spec start_link(Keyword.t()) :: {:ok, pid} | {:error, term}
  def start_link(opts) do
    options =
      case Keyword.fetch(opts, :name) do
        {:ok, nil} -> []
        {:ok, name} -> [name: name]
        :error -> [name: __MODULE__]
      end

    init_opts = Keyword.drop(opts, [:name])

    # Fail early if the required update_interval option is missing
    _ = Keyword.fetch!(init_opts, :update_interval)

    GenServer.start_link(__MODULE__, init_opts, options)
  end

  @doc """
  Retrieve at most two users with point values greater than some threshold
  internal to the gen server.

  Don't ask me, it wasn't me who came up with this idea.
  """
  @spec list_users(pid | atom) :: {[%RCE.Users.User{}], DateTime.t() | nil}
  def list_users(server \\ default_server()) do
    GenServer.call(server, :list_users)
  end

  # These conditional definitions are needed so that we could start a manager
  # process inside a unit test and have it used by default elsewhere, e.g. in
  # some controller action that's being exercised in the test.
  if Mix.env() == :test do
    def default_server do
      Process.get(__MODULE__) || __MODULE__
    end

    def put_default_server(pid) do
      Process.put(__MODULE__, pid)
    end
  else
    def default_server, do: __MODULE__
  end

  ###
  # GenServer behaviour implementation
  ###

  @impl true
  def init(opts) do
    update_interval = Keyword.fetch!(opts, :update_interval)
    debug_pid = Keyword.get(opts, :debug_pid)

    schedule_user_update(update_interval)

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
      :ok ->
        if state.debug_pid, do: send(state.debug_pid, {:updated_users, self()})

      {:error, reason} ->
        Logger.error("Failed to update users", %{reason: inspect(reason)})
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
