# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :fsx,
  generators: [binary_id: true]

# Configures the endpoint
config :fsx, FsxWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Zh3jv5ExTWyuIWrzuNrjUWY/CCQ4QWZV/R9lZBPvT1+7m9sesC/+/mAd2hR54BfO",
  render_errors: [view: FsxWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Fsx.PubSub,
  live_view: [signing_salt: "r+GYyFLk"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
