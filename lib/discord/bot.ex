defmodule Discord.Bot do

  require Logger

  use WebSockex

  alias Discord.API
  alias Discord.Gateway.Frame

  @spec start_link(String.t, :ets.tid, []) :: {:ok, pid}
  def start_link(api_key, table, opts \\ []) do
    {:ok, url} = API.gateway()
    url
      |> socket_url()
      |> WebSockex.start_link(__MODULE__, %{
        endpoint: url,
        api_key: api_key,
        table: table,
        ack: true
      }, opts)
  end

  @doc """
  Invoked on the reception of a frame on the socket.
  """
  def handle_frame({:binary, frame}, state) do
    frame = frame |> :erlang.binary_to_term()
    Logger.debug("Receiving frame #{frame.t}::#{inspect(frame)}")
    update_seq(frame, state.table)
    handle_frame(frame, state)
  end

  @doc """
  Handle the READY frame
  """
  def handle_frame(frame = %{op: 0, t: :READY, d: %{session_id: session_id}}, state) do
    Logger.debug("Ready " <> inspect(state))
    :ets.insert(state.table, {:session_id, session_id})
    {:ok, state}
  end

  @doc """
  Handle the HELLO frame, responding with an identify request
  """
  def handle_frame(%{op: 10, d: %{heartbeat_interval: heartbeat_interval}}, state) do
    pid = self()
    # We send an heartbeat frame after the specified interval
    Process.send_after(self(), :heartbeat, heartbeat_interval)
    # We send an identify frame
    spawn_link fn ->
      :ok = WebSockex.send_frame(pid, Frame.identify(state.api_key))
    end
    # We store the heartbeat interval into the state
    {:ok, Map.put(state, :heartbeat_interval, heartbeat_interval)}
  end

  @doc """
  Handle the heartbeat ACK
  """
  def handle_frame(%{op: 11}, state) do
    {:ok, Map.put(state, :ack, true)}
  end

  @doc """
  Unhandled frame we just log it
  """
  def handle_frame(frame, state) do
    Logger.debug("Received frame #{frame.t}::" <> inspect(frame))
    {:ok, state}
  end

  @doc """
  Handle an :heartbeat process call
  """
  def handle_info(:heartbeat, state = %{ack: true}) do
    pid = self()
    frame = state.table |> last_seq() |> Frame.heartbeat()
    spawn_link fn ->
      :ok = WebSockex.send_frame(pid, frame)
    end
    Process.send_after(self(), :heartbeat, state.heartbeat_interval)
    {:ok, Map.put(state, :ack, false)}
  end

  @doc """
  We did not received an heartbeat ack, we close the connection
  """
  def handle_info(:heartbeat, state = %{ack: false}), do: {:close, state}

  @spec handle_disconnect(map, term) :: {:ok, map}
  def handle_disconnect(connection_status_map, state) do
    Logger.debug("Disconned " <> inspect(connection_status_map))
    {:ok, state}
  end

  @spec terminate(String.t, map) :: any
  def terminate(close_reason, state) do
    Logger.warn(close_reason)
  end

  @spec update_seq(map, :ets.tid) :: boolean
  defp update_seq(frame, table) do
    case Map.get(frame, :s, nil) do
      nil -> false
      s -> :ets.insert(table, {:s, s})
    end
  end

  @spec socket_url(String.t):: String.t
  defp socket_url(url) do
    url
      |> String.trim("/")
      |> Kernel.<>("/?v=#{Discord.API.version()}&encoding=etf")
  end

  @spec last_session_id(tid) :: nil | integer
  defp last_session_id(table) do
    case :ets.lookup(table, :session_id) do
      [session_id: session_id] -> session_id
      _ -> nil
    end
  end

  @spec last_seq(:ets.tid) :: integer | nil
  defp last_seq(table) do
    case :ets.lookup(table, :seq) do
      [seq: seq] -> seq
      _ -> nil
    end
  end

  @spec reset_table(tid) :: true
  defp reset_table(table) do
    :ets.delete_all_objects(table)
  end

end
