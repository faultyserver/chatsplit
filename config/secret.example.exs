# Example secrets file for any environment.
#
# In addition to the `<env>.exs` file, this app relies on a `<env>.secret.exs`
# file containing private information like credentials for Twitch, which
# are kept out of version control so they aren't accidentally made public.
#
# This file shows all of the required configuration options with example values.

config :split, Split.TwitchClient,
  password: "oauth:your_twitch_oauth_token",
  nick: "your_username",
  channels: ["#channelname_1", "#channelname_2"]
