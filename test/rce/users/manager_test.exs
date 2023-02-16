defmodule RCE.Users.ManagerTest do
  use RCE.DataCase, async: true

  alias RCE.Users

  import RCE.UsersFixtures
  import RCE.TestHelpers

  setup do
    %{users: Enum.map(1..10, fn _ -> user_fixture() end)}
  end

  # NOTE: In general, it's best to only test externally visible behaviour of a
  # gen server process, i.e. its public interface.
  # ...

  test "list_users() returns at most two users and ever increasing timestamps" do
    manager = start_user_manager!(update_interval: 1)

    timestamps =
      Enum.map(1..10, fn _ ->
        {users, timestamp} = Users.Manager.list_users(manager)
        assert length(users) <= 2

        # Receive a message from the manager process so that on the next loop
        # iteration we could get an updated list of users.
        #
        # NITPICKY NOTE: it is possible that the users table hasn't been
        # updated between two consecutive calls to list_users() but we don't
        # care about such low-level details here. We just want to have some
        # coverage of the "returns at most 2 users" invariant in this test.
        assert_receive {:updated_users, ^manager}

        timestamp
      end)

    # The first timestamp returned after manager's process startup is known to
    # be nil, so we take it out before checking the remaining timestamp series.
    assert [nil | ts] = timestamps

    Enum.reduce(ts, fn timestamp, last_timestamp ->
      assert DateTime.compare(timestamp, last_timestamp) == :gt
      timestamp
    end)
  end

  test "updates users at regular intervals", %{users: users} do
    # Verify that `users` represents the current state of users in the database
    # before starting the manager process.
    assert users == Users.list_all_users()

    manager = start_user_manager!(update_interval: 1)

    assert_receive {:updated_users, ^manager}
    updated_users = Users.list_all_users()
    refute user_points_map(users) == user_points_map(updated_users)
  end
end
