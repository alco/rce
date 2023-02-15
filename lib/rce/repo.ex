defmodule RCE.Repo do
  use Ecto.Repo,
    otp_app: :rce,
    adapter: Ecto.Adapters.Postgres
end
