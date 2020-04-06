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
    {:ok, _message} = ChatMessage.parse(msg)
    {:ok, state}
  end

  defp _send(pid, message) do
    WebSockex.send_frame(pid, {:text, message})
  end
end
