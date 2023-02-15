defmodule RCEWeb.UserJSON do
  @moduledoc """
  Function component for rendering the User resource.
  """

  # This function could have been inlined in the controller module. But in any
  # serious project it's best to leave request handling to controllers and take
  # response rendering out into a separate module.
  def index(%{users: users, timestamp: timestamp}) do
    users = Enum.map(users, &Map.take(&1, [:id, :points]))
    timestamp = timestamp && Calendar.strftime(timestamp, "%Y-%m-%d %H:%M:%S")
    %{users: users, timestamp: timestamp}
  end
end
