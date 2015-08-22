defmodule ChargifyDirectExample.PageController do
  use ChargifyDirectExample.Web, :controller

  def index(conn, _params) do
    conn
    |> assign(:api_id, api_id)
    |> assign(:timestamp, timestamp)
    |> assign(:nonce, nonce)
    |> assign(:secure_data, secure_data)
    |> assign_signature
    |> render("index.html")
  end

  # http://stackoverflow.com/questions/27082396/how-does-one-generate-an-hmac-string-in-elixir
  # http://www.erlang.org/doc/man/crypto.html
  defp secure_signature(document) do
    :crypto.hmac(:sha, api_secret, document)
    |> Base.encode16
    |> String.downcase
  end

  defp assign_signature(conn) do
    document = conn.assigns.api_id <> to_string(conn.assigns.timestamp) <> conn.assigns.nonce <> conn.assigns.secure_data
    assign(conn, :secure_signature, secure_signature(document) )
  end

  # https://github.com/zyro/elixir-uuid
  defp nonce do
    UUID.uuid1()
  end

  defp secure_data do
    "redirect_uri=http%3A%2F%2Flocalhost%3A4000"
  end

  defp api_id do
    System.get_env("CHARGIFY_DIRECT_API_ID")
  end

  defp api_secret do
    System.get_env("CHARGIFY_DIRECT_API_SECRET")
  end

  # http://essenciary.com/elixir-current-unix-timestamp/
  defp timestamp do
     {ms, s, _} = :os.timestamp
     (ms * 1_000_000) + s
  end

end
