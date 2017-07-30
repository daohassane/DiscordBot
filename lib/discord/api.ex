defmodule Discord.API do
  @moduledoc """
  Permet d'appeller l'API d
  """

  @version 6

  use HTTPoison.Base

  alias HTTPoison.{Error,Response}

  @doc """
  Get the gateway url

  ## Example

    iex> Discord.API.gateway()
    {:ok, "wss://gateway.discord.gg"}
  """
  @spec gateway():: {:ok | :error, String.t}
  def gateway() do
    case get("/gateway") do
      {:ok, %Response{body: %{"url" => url}}} -> {:ok, url}
      {:error, %Error{reason: reason}} -> {:error, reason}
      _ -> {:error, nil}
    end
  end

  @doc """
  Return the current version of the API
  """
  @spec version():: integer
  def version() do
    @version
  end

  @spec process_url(String.t):: String.t
  defp process_url(url) do
    "https://discordapp.com/api/v#{@version}" <> url
  end

  defp process_response_body(body) when is_binary(body) do
    case Poison.decode(body) do
      {:ok, body} -> body
      _ -> body
    end
  end




end
