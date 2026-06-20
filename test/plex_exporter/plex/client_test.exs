defmodule PlexExporter.Plex.ClientTest do
  use ExUnit.Case, async: true

  alias PlexExporter.Plex.Client

  describe "get/2" do
    test "makes a GET request to the path" do
      stub(fn conn ->
        assert conn.method == "GET"
        assert conn.request_path == "/status/info"

        respond(conn)
      end)

      assert {:ok, _} = Client.get("/status/info")
    end

    test "sets Accept header" do
      stub(fn conn ->
        assert Plug.Conn.get_req_header(conn, "accept") == ["application/json"]

        respond(conn)
      end)

      assert {:ok, _} = Client.get("/status/info")
    end

    test "sets X-Plex-Token header" do
      stub(fn conn ->
        assert Plug.Conn.get_req_header(conn, "x-plex-token") == ["token"]

        respond(conn)
      end)

      assert {:ok, _} = Client.get("/status/info")
    end

    test "sets pagination headers only when both offset and limit are set" do
      stub(fn conn ->
        assert Plug.Conn.get_req_header(conn, "x-plex-container-start") == []

        respond(conn)
      end)

      assert {:ok, _} = Client.get("/status/info", offset: 0)
    end

    test "sets pagination headers" do
      stub(fn conn ->
        assert Plug.Conn.get_req_header(conn, "x-plex-container-start") == ["10"]
        assert Plug.Conn.get_req_header(conn, "x-plex-container-size") == ["42"]

        respond(conn)
      end)

      assert {:ok, _} = Client.get("/status/info", offset: 10, limit: 42)
    end

    test "passes through query parameters" do
      stub(fn conn ->
        conn = Plug.Conn.fetch_query_params(conn)

        assert conn.query_params["foo"] == "bar"

        respond(conn)
      end)

      assert {:ok, _} = Client.get("/status/info", params: %{foo: "bar"})
    end

    test "returns 401 errors" do
      stub(fn conn ->
        respond(conn, 401)
      end)

      assert {:error, :unauthorized} = Client.get("/status/info")
    end

    test "returns 403 errors" do
      stub(fn conn ->
        respond(conn, 403)
      end)

      assert {:error, :forbidden} = Client.get("/status/info")
    end

    test "returns 404 errors" do
      stub(fn conn ->
        respond(conn, 404)
      end)

      assert {:error, :not_found} = Client.get("/status/info")
    end

    test "returns successfully" do
      stub(fn conn ->
        respond(conn, 200, ~s({"MediaContainer": {}}))
      end)

      assert {:ok, response} = Client.get("/status/info")

      assert response.status == 200
      assert response.body == %{"MediaContainer" => %{}}
    end
  end

  defp stub(fun), do: Req.Test.stub(Client, fun)

  defp respond(conn, status \\ 200, body \\ "{}") do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(status, body)
  end
end
