defmodule RCE.UsersTest do
  use RCE.DataCase, async: true

  alias RCE.Users

  import RCE.UsersFixtures
  import RCE.TestHelpers

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

    test "refresh_user_points/0 updates points for all users" do
      users = Enum.map(1..10, fn _ -> user_fixture() end)

      # Verify that users represents the current DB state before refreshing the latter.
      assert user_points_map(users) == user_points_map(Users.list_all_users())

      Enum.reduce(1..10, users, fn _, users ->
        assert :ok = Users.refresh_user_points()

        fetched_users = Users.list_all_users()
        refute user_points_map(users) == user_points_map(fetched_users)

        fetched_users
      end)
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Users.change_user(user)
    end
  end
end
