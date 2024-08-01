defmodule ChatroomWeb.ChatroomWeb.ChatLive do
  use ChatroomWeb, :live_view

  alias Chatroom.Chats
  # alias Chatroom.Chats.Message
  alias Chatroom.Accounts

  def mount(%{"id" => chat_id}, session, socket) do
    user_id = session["user_id"]

    case user_id do
      nil ->
        {:ok, redirect(socket, to: "/login")}
      user_id ->
        if connected?(socket) do
          ChatroomWeb.Endpoint.subscribe("chat:#{chat_id}")
        end
        chat = Chats.get_chat!(chat_id)
        user = Accounts.get_user!(user_id)
        message = Chats.list_messages_for_chat(chat_id)
        {:ok, assign(socket, chat: chat, user: user, messages: message)}
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

  def render(assigns) do
    ~H"""
      <div>
        <h1><%= @chat.room_name %></h1>
        <div class="container">
          <%= for message <- @messages do %>
            <div class="message-item">
              <strong><%= message.user.first_name %>:</strong> <%= message.content %>
            </div>
          <% end %>

          <form phx-submit="send_message">
            <input type="text" name="message[content]" placeholder="Type your message..."/>
            <button type="submit" class="btn">Send</button>
          </form>
        </div>
      </div>
    """
  end


end
