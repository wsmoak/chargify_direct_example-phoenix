defmodule ChargifyDirectExample.Web.Router do
  use ChargifyDirectExample.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ChargifyDirectExample.Web do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/callback", PageController, :callback
  end

  # Other scopes may use custom stacks.
  # scope "/api", ChargifyDirectExample.Web do
  #   pipe_through :api
  # end
end
