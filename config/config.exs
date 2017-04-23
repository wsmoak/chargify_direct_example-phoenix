# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :chargify_direct_example, ChargifyDirectExample.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "SqUGKV9FsZytAvjGuk28NC0LEEBGDG6ctw+BsCc32WIFVUIS0VNuMdNAutBiok5F",
  render_errors: [view: ChargifyDirectExample.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ChargifyDirectExample.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
