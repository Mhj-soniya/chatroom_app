defmodule Chatroom.ChatsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Chatroom.Chats` context.
  """

  @doc """
  Generate a chat.
  """
  def chat_fixture(attrs \\ %{}) do
    {:ok, chat} =
      attrs
      |> Enum.into(%{
        room_name: "some room_name"
      })
      |> Chatroom.Chats.create_chat()

    chat
  end

  @doc """
  Generate a message.
  """
  def message_fixture(attrs \\ %{}) do
    {:ok, message} =
      attrs
      |> Enum.into(%{
        content: "some content"
      })
      |> Chatroom.Chats.create_message()

    message
  end
end
