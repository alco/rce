defmodule RCE.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table("users") do
      add :points, :integer, default: 0, null: false
      timestamps()
    end

    create constraint(
             "users",
             "points_must_be_within_range",
             check: "points >= 0 AND points <= 100"
           )
  end
end
