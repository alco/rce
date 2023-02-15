defmodule RCE.UsersTest do
  use RCE.DataCase, async: true

  alias RCE.Users

  import RCE.UsersFixtures

  describe "users" do
    test "list_all_users/0 returns all users" do
      users = Enum.map(1..10, fn _ -> user_fixture() end) |> Enum.sort()
      assert Users.list_all_users() |> Enum.sort() == users
    end

    test "list_users/1 returns users passing the filter criteria" do
      Enum.each(1..8, fn points -> user_fixture(%{points: points}) end)

      fetched_users = Users.list_users(points: {:gt, 4})
      assert length(fetched_users) == 4
      assert Enum.all?(fetched_users, &(&1.points > 4))

      fewer_users = Users.list_users(points: {:gt, 6}, limit: 2)
      assert length(fewer_users) == 2
      assert Enum.all?(fewer_users, &(&1.points > 6))
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Users.change_user(user)
    end
  end
end
