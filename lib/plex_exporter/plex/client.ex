defmodule PlexExporter.Plex.Client do
  @moduledoc """
  HTTP client for making requests to the Plex API
  """

  @typedoc """
  Options to pass to the `Req.Request`
  """
  @type opts :: [params: map(), offset: non_neg_integer(), limit: non_neg_integer()]

  @typedoc """
  Response from `Req`
  """
  @type response :: {:ok, Req.Response.t()} | {:error, :not_found} | {:error, Exception.t()}

  @doc """
  Make a `GET` request to the Plex API
  """
  @spec get(String.t(), opts()) :: response()
  def get(path, opts \\ []) do
    {params, opts} = Keyword.pop(opts, :params, %{})

    response =
      request(opts)
      |> Req.get(url: path, params: params)

    case response do
      {:ok, %Req.Response{status: 200}} -> response
      {:ok, %Req.Response{status: 404}} -> {:error, :not_found}
      {:error, _} -> response
    end
  end

  @spec request(opts()) :: Req.Request.t()
  defp request(opts) do
    Req.new(base_url: "#{Application.fetch_env!(:plex_exporter, :plex_url)}")
    |> Req.Request.put_new_header("Accept", "application/json")
    |> Req.Request.put_new_header(
      "X-Plex-Token",
      Application.fetch_env!(:plex_exporter, :plex_token)
    )
    |> put_pagination_headers(opts)
  end

  @spec put_pagination_headers(Req.Request.t(), opts()) :: Req.Request.t()
  defp put_pagination_headers(request, opts) do
    with {:ok, offset} <- Keyword.fetch(opts, :offset),
         {:ok, limit} <- Keyword.fetch(opts, :limit) do
      request
      |> Req.Request.put_new_header("X-Plex-Container-Start", to_string(offset))
      |> Req.Request.put_new_header("X-Plex-Container-Size", to_string(limit))
    else
      _ -> request
    end
  end
end
