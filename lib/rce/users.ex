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
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end
end
