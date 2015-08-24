defmodule ChargifyDirectExample.PageController do
  use ChargifyDirectExample.Web, :controller

def update_callback(conn, %{"result_code" => "2000"}) do
    conn
    |> render("thanks.html")
  end

  # The result code wasn't 2000 so there must be errors
  def update_callback(conn, %{"call_id" => call_id} ) do

    #TODO: limit the number of API requests for the same call_id
    response = ChargifyV2.Calls.read!(call_id)
    subscription_id = response.body[:call]["request"]["id"]

    conn
    |> put_flash(:error, error_messages_for_call(call_id) )
    |> redirect(to: "/update?sub_id=#{subscription_id}" )
  end

  def callback(conn, %{"result_code" => "2000"}) do
    conn
    |> render("thanks.html")
  end

  # The result code wasn't 2000 so there must be errors
  def callback(conn, %{"call_id" => id} ) do
    conn
    |> put_flash(:error, error_messages_for_call(id) )
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
    data = "redirect_uri=http%3A%2F%2Flocalhost%3A4000%2Fupdate%2Fcallback&amp;subscription_id=" <> conn.assigns.subscription_id

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

  # Returns a string with all error messages for the call
  defp error_messages_for_call(id) do
    ChargifyV2.Calls.read!(id)
    |> ChargifyV2.Calls.error_messages
    |> Enum.join(" ")
  end

end
