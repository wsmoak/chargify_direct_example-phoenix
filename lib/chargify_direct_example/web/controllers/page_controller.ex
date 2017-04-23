defmodule ChargifyDirectExample.Web.PageController do
  use ChargifyDirectExample.Web, :controller

  def index(conn, _params) do
    conn
    |> assign(:api_id, api_id)
    |> assign(:timestamp, timestamp)
    |> assign(:nonce, uuid)
    |> assign(:uniqueness_token, uuid)
    |> assign(:secure_data, secure_data)
    |> assign_secure_signature
    |> assign(:client_token, client_token)
    |> render("index.html")
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

  defp api_id do
    System.get_env("CHARGIFY_DIRECT_API_ID")
  end

  # http://essenciary.com/elixir-current-unix-timestamp/
  defp timestamp do
     {ms, s, _} = :os.timestamp
     (ms * 1_000_000) + s
  end

  # https://github.com/zyro/elixir-uuid
  defp uuid do
    UUID.uuid1()
  end

  defp secure_data do
    "redirect_uri=http%3A%2F%2Flocalhost%3A4000%2Fcallback"
  end

  defp assign_secure_signature(conn) do
    document = conn.assigns.api_id <> to_string(conn.assigns.timestamp) <> conn.assigns.nonce <> conn.assigns.secure_data

    assign(conn, :secure_signature, secure_signature(document) )
  end

  # https://docs.chargify.com/chargify-direct-introduction#secure-parameters-signature
  # http://stackoverflow.com/questions/27082396/how-does-one-generate-an-hmac-string-in-elixir
  # http://www.erlang.org/doc/man/crypto.html
  defp secure_signature(document) do
    :crypto.hmac(:sha, api_secret, document)
    |> Base.encode16
    |> String.downcase
  end

  defp api_secret do
    System.get_env("CHARGIFY_DIRECT_API_SECRET")
  end

  # Returns a string with all error messages for the call
  defp error_messages_for_call(id) do
    ChargifyV2.Calls.read!(id)
    |> IO.inspect
    |> ChargifyV2.Calls.error_messages
    |> Enum.join(" ")
  end

  # Hard code Braintree client token generated at command prompt with ruby
  defp client_token do
    "eyJ2ZXJzaW9uIjoyLCJhdXRob3JpemF0aW9uRmluZ2VycHJpbnQiOiI5MzAyZjk4ODczMTIzOGY4ODEwMTk1NDMyOWRhNmY2MTMyZGIwNTM2NjYzODgxOWIzNDFmMDhmZGU4ZTQ0MmZlfGNyZWF0ZWRfYXQ9MjAxNS0wOS0xMVQyMTo0MDo0Mi4zMjUxODkwNzkrMDAwMFx1MDAyNm1lcmNoYW50X2lkPWp0c2hmdHE2ZzJta3JudDhcdTAwMjZwdWJsaWNfa2V5PXB3ajljZm5mNXN6NjRxNGQiLCJjb25maWdVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvanRzaGZ0cTZnMm1rcm50OC9jbGllbnRfYXBpL3YxL2NvbmZpZ3VyYXRpb24iLCJjaGFsbGVuZ2VzIjpbXSwiZW52aXJvbm1lbnQiOiJzYW5kYm94IiwiY2xpZW50QXBpVXJsIjoiaHR0cHM6Ly9hcGkuc2FuZGJveC5icmFpbnRyZWVnYXRld2F5LmNvbTo0NDMvbWVyY2hhbnRzL2p0c2hmdHE2ZzJta3JudDgvY2xpZW50X2FwaSIsImFzc2V0c1VybCI6Imh0dHBzOi8vYXNzZXRzLmJyYWludHJlZWdhdGV3YXkuY29tIiwiYXV0aFVybCI6Imh0dHBzOi8vYXV0aC52ZW5tby5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIiwiYW5hbHl0aWNzIjp7InVybCI6Imh0dHBzOi8vY2xpZW50LWFuYWx5dGljcy5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIn0sInRocmVlRFNlY3VyZUVuYWJsZWQiOnRydWUsInRocmVlRFNlY3VyZSI6eyJsb29rdXBVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvanRzaGZ0cTZnMm1rcm50OC90aHJlZV9kX3NlY3VyZS9sb29rdXAifSwicGF5cGFsRW5hYmxlZCI6dHJ1ZSwicGF5cGFsIjp7ImRpc3BsYXlOYW1lIjoiV2VuZHkgU21vYWsiLCJjbGllbnRJZCI6bnVsbCwicHJpdmFjeVVybCI6Imh0dHA6Ly9leGFtcGxlLmNvbS9wcCIsInVzZXJBZ3JlZW1lbnRVcmwiOiJodHRwOi8vZXhhbXBsZS5jb20vdG9zIiwiYmFzZVVybCI6Imh0dHBzOi8vYXNzZXRzLmJyYWludHJlZWdhdGV3YXkuY29tIiwiYXNzZXRzVXJsIjoiaHR0cHM6Ly9jaGVja291dC5wYXlwYWwuY29tIiwiZGlyZWN0QmFzZVVybCI6bnVsbCwiYWxsb3dIdHRwIjp0cnVlLCJlbnZpcm9ubWVudE5vTmV0d29yayI6dHJ1ZSwiZW52aXJvbm1lbnQiOiJvZmZsaW5lIiwidW52ZXR0ZWRNZXJjaGFudCI6ZmFsc2UsImJyYWludHJlZUNsaWVudElkIjoibWFzdGVyY2xpZW50MyIsImJpbGxpbmdBZ3JlZW1lbnRzRW5hYmxlZCI6ZmFsc2UsIm1lcmNoYW50QWNjb3VudElkIjoiaHB4Zm42N2NxNHprc2M1MiIsImN1cnJlbmN5SXNvQ29kZSI6IlVTRCJ9LCJjb2luYmFzZUVuYWJsZWQiOmZhbHNlLCJtZXJjaGFudElkIjoianRzaGZ0cTZnMm1rcm50OCIsInZlbm1vIjoib2ZmIn0="
  end
end
