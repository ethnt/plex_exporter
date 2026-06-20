defmodule PlexExporter.Collectors.SessionsTest do
  use PlexExporter.CollectorCase, async: true

  alias PlexExporter.Collectors.Sessions

  describe "count/0" do
    test "returns 0 sessions when there are no sessions" do
      PlexExporter.Plex.Status
      |> expect(:sessions, fn -> {:ok, %Req.Response{body: %{"MediaContainer" => %{}}}} end)

      assert {:ok, %{direct_play: 0, direct_stream: 0, transcode: 0}} = Sessions.count()
    end

    test "counts direct play sessions" do
      PlexExporter.Plex.Status
      |> expect(:sessions, fn ->
        {:ok,
         %Req.Response{
           body: %{
             "MediaContainer" => %{
               "Metadata" => [
                 %{"Media" => [%{"Part" => [%{"decision" => "directplay"}]}]}
               ]
             }
           }
         }}
      end)

      assert {:ok, %{direct_play: 1, direct_stream: 0, transcode: 0}} = Sessions.count()
    end

    test "counts direct steam sessions" do
      PlexExporter.Plex.Status
      |> expect(:sessions, fn ->
        {:ok,
         %Req.Response{
           body: %{
             "MediaContainer" => %{
               "Metadata" => [
                 %{
                   "TranscodeSession" => %{"videoDecision" => "copy"},
                   "Media" => [%{"Part" => [%{"decision" => "directStream"}]}]
                 }
               ]
             }
           }
         }}
      end)

      assert {:ok, %{direct_play: 0, direct_stream: 1, transcode: 0}} = Sessions.count()
    end

    test "counts video transcode sessions" do
      PlexExporter.Plex.Status
      |> expect(:sessions, fn ->
        {:ok,
         %Req.Response{
           body: %{
             "MediaContainer" => %{
               "Metadata" => [
                 %{"TranscodeSession" => %{"videoDecision" => "transcode"}}
               ]
             }
           }
         }}
      end)

      assert {:ok, %{direct_play: 0, direct_stream: 0, transcode: 1}} = Sessions.count()
    end

    test "counts audio transcode sessions" do
      PlexExporter.Plex.Status
      |> expect(:sessions, fn ->
        {:ok,
         %Req.Response{
           body: %{
             "MediaContainer" => %{
               "Metadata" => [
                 %{"TranscodeSession" => %{"audioDecision" => "transcode"}}
               ]
             }
           }
         }}
      end)

      assert {:ok, %{direct_play: 0, direct_stream: 0, transcode: 1}} = Sessions.count()
    end

    test "returns error when sessions call fails" do
      PlexExporter.Plex.Status
      |> expect(:sessions, fn -> {:error, :unauthorized} end)

      assert {:error, :unauthorized} = Sessions.count()
    end
  end
end
