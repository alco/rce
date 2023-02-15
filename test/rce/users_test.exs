defmodule RCE.UsersTest do
  use RCE.DataCase, async: true

  alias RCE.Users

  import RCE.UsersFixtures

  describe "users" do
    test "list_all_users/0 returns all users" do
      users = Enum.map(1..10, fn _ -> user_fixture() end) |> Enum.sort()
      assert Users.list_all_users() |> Enum.sort() == users
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Users.change_user(user)
    end
  end
end
