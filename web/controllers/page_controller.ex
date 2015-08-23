defmodule ChargifyDirectExample.PageController do
  use ChargifyDirectExample.Web, :controller

  def callback(conn, %{"result_code" => "2000"}) do
    conn
    |> render("thanks.html")
  end

  def callback(conn, %{"call_id" => call_id} ) do
    response = ChargifyV2.get!("/calls/" <> call_id)
    errors = response.body[:call]["response"]["result"]["errors"]
    messages = Enum.map(errors, &Dict.fetch!(&1, "message"))

    conn
    |> put_flash(:error, Enum.join(messages," ") )
    |> redirect(to: "/" )
  end

  def index(conn, _params) do
    conn
    |> assign(:api_id, api_id)
    |> assign(:timestamp, timestamp)
    |> assign(:nonce, nonce)
    |> assign(:secure_data, secure_data)
    |> assign_secure_signature
    |> render("index.html")
  end

  def update(conn, %{"sub_id" => subscription_id} ) do
    conn
    |> assign(:subscription_id, subscription_id)
    |> assign(:api_id, api_id)
    |> assign(:timestamp, timestamp)
    |> assign(:nonce, nonce)
    |> assign_secure_data_for_update
    |> assign_secure_signature
    |> render("update.html")
  end

  # https://docs.chargify.com/chargify-direct-introduction#secure-parameters-signature
  # http://stackoverflow.com/questions/27082396/how-does-one-generate-an-hmac-string-in-elixir
  # http://www.erlang.org/doc/man/crypto.html
  defp secure_signature(document) do
    :crypto.hmac(:sha, api_secret, document)
    |> Base.encode16
    |> String.downcase
  end

  defp assign_secure_signature(conn) do
    document = conn.assigns.api_id <> to_string(conn.assigns.timestamp) <> conn.assigns.nonce <> conn.assigns.secure_data

    assign(conn, :secure_signature, secure_signature(document) )
  end

  # https://github.com/zyro/elixir-uuid
  defp nonce do
    UUID.uuid1()
  end

  defp secure_data do
    "redirect_uri=http%3A%2F%2Flocalhost%3A4000%2Fcallback"
  end

  defp assign_secure_data_for_update(conn) do
    data = "redirect_uri=http%3A%2F%2Flocalhost%3A4000%2Fcallback&subscription_id=" <> conn.assigns.subscription_id

    assign(conn, :secure_data, data)
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
