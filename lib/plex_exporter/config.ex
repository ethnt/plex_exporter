defmodule PlexExporter.Config do
  defstruct [:url, :token]

  @type t :: %__MODULE__{
          url: String.t(),
          token: String.t()
        }
end
