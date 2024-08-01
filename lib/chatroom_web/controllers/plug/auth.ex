defmodule ChatroomWeb.Plug.Auth do

  import Plug.Conn

  alias Chatroom.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)
    IO.inspect(user_id, label: "AuthPlug UserID")

    user = case user_id do
      nil -> nil
      _ -> Accounts.get_user!(user_id)
    end

    conn
    |> assign(:current_user, user)

  end
end
