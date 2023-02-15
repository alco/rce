defmodule RCEWeb.UserController do
  use RCEWeb, :controller

  alias RCE.Users

  def index(conn, _params) do
    {users, timestamp} = Users.Manager.list_users()
    render(conn, :index, users: users, timestamp: timestamp)
  end
end
