defmodule Chatroom.Chats.Chat do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chats" do
    field :room_name, :string

    has_many :messages, Chatroom.Chats.Message

    timestamps(type: :utc_datetime)
  end


  @doc false
  def changeset(chat, attrs \\ %{}) do
    chat
    |> cast(attrs, [:room_name])
    |> validate_required([:room_name])
  end
end
