# RCE

A coding exercise.

_#Elixir_ _#Phoenix_ _#JSON API_


## Setup

Run `mix setup` once to fetch mix dependencies and populate the DB with seed data.

```
$ mix setup
```


## Running the server

Start the Phoenix server.

```
$ mix phx.server
```

Then navigate to http://localhost:4000 to fetch the JSON containing zero, one,
or two users and the timestamp of the previous fetch (not necessarily performed
by the same client).

Every time you hit the endpoint, a different set of users may be returned.

Once a minute all users' points are updated with random values.