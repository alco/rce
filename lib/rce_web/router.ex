defmodule RCEWeb.Router do
  use RCEWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", RCEWeb do
    pipe_through :api
  end
end
