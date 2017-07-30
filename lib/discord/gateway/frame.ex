defmodule Discord.Gateway.Frame do
  @moduledoc ~S"""
  Generate frame for API Gateway

  ## Opcodes

  dispatch: 0,
  heartbeat: 1
  identify: 2
  status_update: 3
  voice_state_update: 4
  voice_ping: 5
  resumt: 6
  reconnect: 7
  request_guild_members: 8
  invalid_session: 9
  hello: 10
  heartbeat_ack: 11
  """

  @type frame :: {:binary, :erlang.ext_binary}

  @spec identify(String.t) :: frame
  def identify(api_key) do
    %{
      "op" => 2,
      "d" => %{
        "token" => api_key,
        "properties" => %{
            "$os" => "linux",
            "$browser" => "elixir-vm",
            "$device" => "elixir-vm"
        },
        "compress" => false,
        "large_threshold" => 50
      }
    } |> to_frame()
  end

  @spec heartbeat(integer | nil) :: frame
  def heartbeat(seq) do
    %{
      "op" => 1,
      "d" => seq
    } |> to_frame()
  end

  @spec to_frame(map) :: frame
  defp to_frame(map) do
    {:binary, :erlang.term_to_binary(map)}
  end

end