# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs

alias RCE.Repo

# make sure the users table is empty before executing the large insert to make
# this seed script idempotent.
if not Repo.exists?(RCE.Users.User) do
  # This works without specifying any values because all columns in the "users"
  # table have default values.
  Repo.query!("INSERT INTO users SELECT FROM generate_series(1, 1000000)")
end
