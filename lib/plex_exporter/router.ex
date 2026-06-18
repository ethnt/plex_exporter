defmodule PlexExporter.Router do
  use Plug.Router

  plug(PlexExporter.Plug)
  plug(:match)
  plug(:dispatch)

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
