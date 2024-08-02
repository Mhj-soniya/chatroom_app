defmodule ChatroomWeb.ChatroomWeb.ChatLive do
  use ChatroomWeb, :live_view

  alias Chatroom.Chats
  # alias Chatroom.Chats.Message
  alias Chatroom.Accounts
  alias ChatroomWeb.Presence

  def mount(%{"id" => chat_id}, session, socket) do
    user_id = session["user_id"]

    socket = stream(socket, :presences, [])

    case user_id do
      nil ->
        {:ok, redirect(socket, to: "/login")}
      user_id ->
        user = Accounts.get_user!(user_id)
        if connected?(socket) do
          ChatroomWeb.Endpoint.subscribe("chat:#{chat_id}")
          Presence.track_user(user.first_name, %{id: user.first_name})
          Presence.subscribe()

          # Debug: Log user and chat_id
          IO.inspect(user.first_name, label: "Tracking user")
          IO.inspect(chat_id, label: "Chat ID")


          # Fetch and stream the list of currently online users
          # presences = Presence.list("online_users")

          # Debugging: Inspect the fetched presences
          # IO.inspect(presences, label: "Presences on mount")

          # stream(socket, :presences, presences)
        end

        chat = Chats.get_chat!(chat_id)
        message = Chats.list_messages_for_chat(chat_id)
        online_users = Presence.list_online_users()

        socket =
          socket
          |> put_flash(:info, "Welcome to the room")
          |> assign(chat: chat, user: user, messages: message)
          |> stream(:presences, online_users)

        {:ok, socket}
    end
  end

  def handle_event("send_message", %{"message" => message_params}, socket) do
    user = socket.assigns.user
    chat = socket.assigns.chat
    IO.inspect(user.id, label: "user_id")
    IO.inspect(chat.id, label: "chat_id")
    case Chats.create_message(%{chat_id: chat.id, user_id: user.id, content: message_params["content"]}) do
      {:ok, message} ->
        # Broadcast the new message
        ChatroomWeb.Endpoint.broadcast("chat:#{chat.id}", "new_message", %{
          message: message,
          user: socket.assigns.user
        })

        {:noreply, update(socket, :messages, fn messages -> [message | messages] end)}
      {:error, _reason} ->
        {:noreply, socket}
    end
  end

  def handle_info(%{event: "new_message", payload: %{message: message}}, socket) do
    {:noreply, update(socket, :messages, fn messages -> [message | messages] end)}
  end

  def handle_info({Presence, {:join, presence}}, socket) do
    {:noreply, stream_insert(socket, :presences, presence)}
    # {:noreply, stream_insert(socket, :online_users, user_data)}
  end

  def handle_info({Presence, {:leave, presence}}, socket) do
    if presence.metas == [] do
      {:noreply, stream_delete(socket, :presences, presence)}
    else
      {:noreply, stream_insert(socket, :presences, presence)}
    end
  end

  # def handle_info(%{event: "presence_diff", payload: %{joins: joins, leaves: leaves}}, socket) do
  #   presences = socket.assigns.presences
  #   presences = Map.merge(presences, joins, fn _key, _v1, v2 -> v2 end)
  #   presences = Map.drop(presences, Map.keys(leaves))
  #   {:noreply, assign(socket, presences: presences)}
  # end

  def render(assigns) do
    ~H"""
    <div class="flex">
      <div class="sidebar">
        <h2>Online Users:</h2>
        <ul id="online_users" phx-update="stream">
          <li :for={{dom_id, %{id: id, metas: metas}} <- @streams.presences} id={dom_id}><%= id %> <!--(<%= length(metas) %>)--></li>
        </ul>
      </div>

      <div class="container">
        <h1><%= @chat.room_name %></h1>
        <div class="messages">
          <%= for message <- @messages do %>
            <div class="message-item">
              <strong><%= message.user.first_name %>:</strong> <%= message.content %>
            </div>
          <% end %>
        </div>
        <form phx-submit="send_message">
          <input type="text" name="message[content]" placeholder="Type your message..."/>
          <button type="submit" class="btn">Send</button>
        </form>
      </div>
    </div>
    """
  end


end
