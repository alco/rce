defmodule RCEWeb.Router do
  use RCEWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", RCEWeb do
    pipe_through :api

    get "/", UserController, :index
  end
end
