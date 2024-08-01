defmodule ChatroomWeb.LoginController do
  use ChatroomWeb, :controller

  alias Chatroom.Repo
  alias Chatroom.Accounts.User

  def new(conn, _params) do
    render(conn, :new)
  end

  def authenticate(conn, %{"_csrf_token"=>_token, "email"=>email, "password"=>password}) do
    case Repo.get_by(User, email: email) do
      nil ->
        conn
        |> put_flash(:error, "Invalid Email or Password")
        |> redirect(to: "/login")
      user ->
        if password == user.password do
          conn
          |> put_session(:user_id, user.id)
          |> put_flash(:info, "Logged in successfully")
          |> redirect(to: "/rooms")
        else
          conn
          |> put_flash(:error, "Invalid email or password")
          |> redirect(to: "/login")
        end
    end
  end

end
