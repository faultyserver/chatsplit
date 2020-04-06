defmodule Split.ChatMessage do
  defstruct(
    tags: %{},
    sender: nil,
    type: nil,
    channel: nil,
    content: nil
  )

  # Messages starting with @ include tag information at the start. The resulting
  # form is:
  #
  #   @tags :sender TYPE #channel :content
  def parse("@" <> tagged_message) do
    parts =
      tagged_message
      |> String.split(" ", parts: 5)

    [tags, sender, type, channel, content] = parts

    message = %__MODULE__{
      tags: parse_tags(tags),
      sender: parse_sender(sender),
      type: type,
      channel: parse_channel(channel),
      content: parse_content(content)
    }

    {:ok, message}
  end

  def parse(message) do
    {:ok, message}
  end

  defp parse_tags(tags) do
    tags
    |> String.split(";")
    |> Enum.map(&parse_tag/1)
    |> Map.new(fn [k, v] -> {k, v} end)
  end

  def parse_tag(tag) do
    tag
    |> String.split("=")
  end

  defp parse_sender(":" <> sender), do: sender

  defp parse_channel("#" <> channel), do: channel

  defp parse_content(":" <> content) do
    content
    |> String.trim()
  end
end
