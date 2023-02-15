defmodule RCE.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias RCE.Repo

  alias RCE.Users.User

  @doc """
  Returns the list of all users.

  ## Examples

      iex> list_all_users()
      [%User{}, ...]

  """
  def list_all_users do
    Repo.all(User)
  end

  @doc """
  Returns the list of users matching the specified criteria.

  ## Examples

      iex> list_users(points: {:gt, 10})
      [%User{}, ...]  # a list of all users that have more than 10 points

      Iex> list_users(limit: 10)
      [%User{}, ...]  # a list of ten users fetched from the DB,
                      # in no particular order
  """
  def list_users(filters) do
    query =
      Enum.reduce(filters, User, fn
        {:points, {:gt, value}}, query -> where(query, [user], user.points > ^value)
        {:limit, limit}, query -> limit(query, [user], ^limit)
      end)

    Repo.all(query)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end
end
