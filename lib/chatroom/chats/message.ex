defmodule Chatroom.Chats.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :content, :string
    belongs_to :user, Chatroom.Accounts.User
    belongs_to :chat, Chatroom.Chats.Chat

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :user_id, :chat_id])
    |> validate_required([:content, :user_id, :chat_id])
  end
end
