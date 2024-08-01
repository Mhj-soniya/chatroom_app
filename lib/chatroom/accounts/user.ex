defmodule Chatroom.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :password, :string
    field :first_name, :string
    field :last_name, :string
    field :email, :string

    has_many :messages, Chatroom.Chats.Message

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [:first_name, :last_name, :email, :password])
    |> validate_required([:first_name, :last_name, :email, :password])
    |> validate_length(:password, min: 6)
    |> validate_format(:email, ~r/^[a-zA-Z0-9-+.*&]+@[a-zA-Z0-9-]+\.[a-zA-Z]{2,}$/)
    |> unique_constraint(:email)
  end
end
