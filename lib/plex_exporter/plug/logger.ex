defmodule PlexExporter.Plug.Logger do
  @moduledoc false

  @behaviour Plug

  require Logger

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, _opts) do
    start = System.monotonic_time()

    Plug.Conn.register_before_send(conn, fn conn ->
      ms = System.convert_time_unit(System.monotonic_time() - start, :native, :millisecond)

      Logger.debug(%{
        component: "router",
        method: conn.method,
        path: conn.request_path,
        status: conn.status,
        duration_ms: ms
      })

      conn
    end)
  end
end
