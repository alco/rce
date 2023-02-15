defmodule RCEWeb.UserControllerTest do
  use RCEWeb.ConnCase, async: true

  import RCE.UsersFixtures

  setup %{conn: conn} do
    %{
      conn: put_req_header(conn, "accept", "application/json"),
      user_manager: RCE.TestHelpers.start_user_manager!()
    }
  end

  describe "index" do
    test "fetches at most two users and a timestamp", %{conn: conn} do
      Enum.each(1..100, fn _ -> user_fixture() end)

      conn = get(conn, ~p"/")
      assert %{"users" => fetched_users, "timestamp" => _} = json_response(conn, 200)
      assert length(fetched_users) <= 2
    end

    test "may return a nil timestamp", %{conn: conn} do
      conn = get(conn, ~p"/")
      assert json_response(conn, 200) == %{"timestamp" => nil, "users" => []}
    end

    test "returns properly formatted timestamps", %{conn: conn} do
      # skip the nil timestamp
      get(conn, ~p"/")

      conn = get(conn, ~p"/")
      assert %{"timestamp" => timestamp} = json_response(conn, 200)

      # Append Z to the timestamp to make it look like an ISO-8601 formatted
      # datetime. This allows us to parse the string without introducing
      # external dependencies.
      assert {:ok, datetime, 0} = DateTime.from_iso8601(timestamp <> "Z")

      # Using a 10-second range is me being overly cautions but I just don't
      # want to see flaky tests in CI reports.
      diff = DateTime.diff(DateTime.utc_now(), datetime)
      assert diff >= 0
      assert diff < 10
    end
  end
end
