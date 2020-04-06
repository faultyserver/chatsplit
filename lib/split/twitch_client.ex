defmodule Split.TwitchClient do
  use WebSockex
  require Logger

  alias Split.ChatMessage

  def start_link(opts \\ []) do
    config = Application.fetch_env!(:split, __MODULE__)
    twitch_host = config[:twitch_host]
    oauth_token = config[:oauth_token]
    nickname = config[:nickname]
    channels = config[:channels]

    Logger.warn("Reconnecting to channel")
    {:ok, pid} = WebSockex.start_link(twitch_host, __MODULE__, :fake_state, opts)

    _send(pid, "PASS " <> oauth_token)
    _send(pid, "NICK " <> nickname)
    _send(pid, "CAP REQ :twitch.tv/tags twitch.tv/commands")

    channels
    |> Enum.each(fn channel -> _send(pid, "JOIN #{channel}") end)

    {:ok, pid}
  end

  def handle_connect(_conn, state) do
    Logger.debug("Connected to channel")
    {:ok, state}
  end

  def handle_frame({_type, msg}, state) do
    {:ok, message} = ChatMessage.parse(msg)

    case message do
      %{type: "PRIVMSG"} -> show_message_bucket(message)
      _ -> false
    end

    {:ok, state}
  end

  def show_message_bucket(%{tags: tags, content: content}) do
    id = tags["id"]

    <<_::binary-size(8), hash::unsigned-little-integer-size(64)>> = :erlang.md5(id)
    bucket = Kernel.rem(hash, 32)

    IO.inspect(%{id: id, hash: hash, bucket: bucket, content: content})
  end

  defp _send(pid, message) do
    WebSockex.send_frame(pid, {:text, message})
  end
end
