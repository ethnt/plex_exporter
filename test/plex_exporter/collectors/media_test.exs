defmodule PlexExporter.Collectors.MediaTest do
  use PlexExporter.CollectorCase, async: true

  import Mimic

  alias PlexExporter.Collectors.Media
  alias PlexExporter.Plex.Library

  describe "count/0" do
    test "returns empty list when there are no sections" do
      expect(Library, :sections, fn -> {:ok, %Req.Response{body: %{"MediaContainer" => %{}}}} end)
      assert {:ok, []} = Media.count()
    end

    test "returns count for a movie library" do
      Library
      |> expect(:sections, fn ->
        {:ok,
         %Req.Response{
           body: %{
             "MediaContainer" => %{
               "Directory" => [%{"title" => "Movies", "key" => "1", "type" => "movie"}]
             }
           }
         }}
      end)
      |> expect(:section, fn "1", _ ->
        {:ok, %Req.Response{headers: %{"x-plex-container-total-size" => ["42"]}}}
      end)

      assert {:ok, [%{title: "Movies", type: "movie", count: 42}]} = Media.count()
    end

    test "returns count and episode count for a show library" do
      Library
      |> expect(:sections, fn ->
        {:ok,
         %Req.Response{
           body: %{
             "MediaContainer" => %{
               "Directory" => [%{"title" => "TV Shows", "key" => "2", "type" => "show"}]
             }
           }
         }}
      end)
      |> expect(:section, fn "2", _ ->
        {:ok, %Req.Response{headers: %{"x-plex-container-total-size" => ["10"]}}}
      end)
      |> expect(:section, fn "2", _ ->
        {:ok, %Req.Response{headers: %{"x-plex-container-total-size" => ["150"]}}}
      end)

      assert {:ok,
              [
                %{title: "TV Shows", type: "show", count: 10},
                %{title: "TV Shows - Episodes", type: "show_episode", count: 150}
              ]} =
               Media.count()
    end

    test "returns error when sections call fails" do
      expect(Library, :sections, fn -> {:error, :unauthorized} end)
      assert {:error, :unauthorized} = Media.count()
    end
  end
end
