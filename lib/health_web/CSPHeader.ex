defmodule HealthWeb.CSPHeader do
  @moduledoc """
    Plug to set Content-Security-Policy with websocket endpoints
  """

  alias Phoenix.Controller
  alias Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    Controller.put_secure_browser_headers(conn, %{
      "content-security-policy" => "\
                 connect-src 'self' #{websocket_endpoints(conn)}; \
                 default-src 'self';\
                 script-src 'self' 'unsafe-inline' 'unsafe-eval' https://code.jquery.com https://stackpath.bootstrapcdn.com https://cdn.jsdelivr.net;\
                 style-src 'self' 'unsafe-inline' 'unsafe-eval' https://fonts.googleapis.com https://stackpath.bootstrapcdn.com;\
                 img-src 'self' 'unsafe-inline' 'unsafe-eval' data:;\
                 font-src 'self' 'unsafe-inline' 'unsafe-eval' https://fonts.gstatic.com data:;\
      "

    })
  end

  defp websocket_endpoints(conn) do
    host = Conn.get_req_header(conn, "host")
    "ws://#{host} wss://#{host}"
  end
end
