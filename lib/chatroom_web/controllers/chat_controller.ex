defmodule ChatroomWeb.ChatController do
  use ChatroomWeb, :controller

  alias Chatroom.Chats
  alias Chatroom.Chats.Chat

  # Use the Auth plug to ensure the user is authenticated
  plug ChatroomWeb.Plug.Auth when action in [:new, :create]
  plug :authenticate_user when action in [:new, :create]

  defp authenticate_user(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "You need to log in to access this page")
      |> redirect(to: "/login")
      |> halt()
    end
  end

  def new(conn, _params) do
    rooms = Chats.list_chats()
    render(conn, :new, changeset: Chat.changeset(%Chat{}), rooms: rooms)
  end

  def create(conn, %{"chat" => chat_params}) do
    case Chats.create_chat(chat_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Chatroom created.")
        |> redirect(to: "/rooms")
      {:error, _} ->
        conn
        |> redirect(to: "/rooms")
    end
  end

end
