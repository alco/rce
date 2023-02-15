defmodule RCE.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `RCE.Users` context.
  """

  @doc """
  Generate a user with a random amount of points.
  """
  def user_fixture(attrs \\ %{}) do
    attrs = Map.merge(%{points: :rand.uniform(101) - 1}, attrs)

    struct(RCE.Users.User, attrs)
    |> RCE.Repo.insert!()
  end
end
