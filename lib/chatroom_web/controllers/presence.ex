defmodule ChatroomWeb.Presence do
  use Phoenix.Presence,
    otp_app: :chatroom,
    pubsub_server: Chatroom.PubSub


  def init(_opts) do
    {:ok, %{}}
  end

  #allows data fetched from presence to be modified
  def fetch(_topic, presences) do
    for {key, %{metas: [meta | metas]}} <- presences, into: %{} do
      #user can be populated here from the db
      {key, %{metas: [meta | metas], id: meta.id, user: %{name: meta.id}}}
    end
  end

  #update the state that we keep track of in Chatroom.Presence
  def handle_metas(topic, %{joins: joins, leaves: leaves}, presences, state) do
    for {user_id, presence} <- joins do
      user_data = %{id: user_id, user: presence.user, metas: Map.fetch!(presences, user_id)}
      msg = {__MODULE__, {:join, user_data}}
      Phoenix.PubSub.local_broadcast(Chatroom.PubSub, "proxy:#{topic}", msg)
    end

    for {user_id, presence} <- leaves do
      metas =
        case Map.fetch(presence, user_id) do
          {:ok, presence_metas} -> presence_metas
          :error -> []
        end

      user_data = %{id: user_id, user: presence.user, metas: metas}
      msg = {__MODULE__, {:leave, user_data}}
      Phoenix.PubSub.local_broadcast(Chatroom.PubSub, "proxy:#{topic}", msg)
    end

  {:ok, state}

  end

  def list_online_users(), do: list("online_users") |> Enum.map(fn {_id, presence} -> presence end)

  def track_user(name, params) do
    IO.puts("Tracking user: #{name}")
    IO.puts("PID: #{inspect(self())}")
    case track(self(), "online_users", name, params) do
      {:ok, _} -> IO.puts("User #{name} tracked successfully.")
      {:error, reason} -> IO.puts("Failed to track user #{name}: #{inspect(reason)}")
    end
  end

  def subscribe(), do: Phoenix.PubSub.subscribe(Chatroom.PubSub, "proxy:online_users")

end
