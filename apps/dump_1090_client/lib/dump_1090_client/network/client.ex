defmodule Dump1090Client.Network.Client do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    state = opts_to_initial_state(opts)
    connect(state)
  end

  defp connect(state) do
    case :gen_tcp.connect(state.host, state.port, []) do
      {:ok, _socket} ->
        state.on_connect.(state)
        {:ok, state}
      {:error, _reason} ->
        new_state = %{state | failure_count: 1}
        new_state.on_disconnect.(new_state)
        {:ok, new_state, state.retry_interval}
    end
  end

  def handle_info({:tcp, _socket, message}, state) do
    Phoenix.PubSub.broadcast(Aircraft.channel, Aircraft.raw_adsb_topic, {:raw, List.to_string(message)})
    case Aircraft.ParseAdsb.parse(List.to_string(message)) do
      aircraft = %Aircraft{icoa: _icoa} ->
        Phoenix.PubSub.broadcast(Aircraft.channel, Aircraft.update_topic, {:update, aircraft})
      :not_supported ->
        :ok
    end
    {:noreply, state}
  end

  def handle_info(:timeout, state = %{failure_count: failure_count}) do
    if failure_count <= state.max_retries do
      case :gen_tcp.connect(state.host, state.port, []) do
        {:ok, _socket} ->
          new_state = %{state | failure_count: 0}
          new_state.on_connect.(new_state)
          {:noreply, new_state}
        {:error, _reason} ->
          new_state = %{state | failure_count: failure_count + 1}
          new_state.on_disconnect.(new_state)
          :timer.sleep(state.retry_delay)
          {:noreply, new_state, state.retry_interval}
      end
    else
      state.on_retries_exceeded.(state)
      {:stop, :max_retry_exceeded, state}
    end
  end

  # not used?
  # def handle_info({:tcp_closed, _socket}, state) do
  #   case :gen_tcp.connect(state.host, state.port, []) do
  #     {:ok, _socket} ->
  #       new_state = %{state | failure_count: 0}
  #       new_state.on_connect.(new_state)
  #       {:noreply, new_state}
  #     {:error, _reason} ->
  #       new_state = %{state | failure_count: 1}
  #       new_state.on_disconnect.(new_state)
  #       {:noreply, new_state, state.retry_interval}
  #   end
  # end

  defp opts_to_initial_state(opts) do
    state = %{
      host: "localhost",
      port: 30003,
      max_retries: 10,
      retry_interval: 1000,
      retry_delay: 60000,
      failure_count: 0,
      on_connect: fn state ->
        Logger.debug("tcp connect to #{state.host}:#{state.port}", ansi_color: :light_blue)
      end,
      on_disconnect: fn state ->
        Logger.debug("tcp disconnect from #{state.host}:#{state.port}", ansi_color: :light_blue)
      end,
      on_retries_exceeded: fn state ->
        Logger.info("Max retries exceeded for #{state.host}:#{state.port}.")
      end,
    }

    state = if Keyword.has_key?(opts, :host) do
      %{ state | host: Keyword.get(opts, :host, "localhost") |> String.to_charlist }
    else
      state
    end

    state = if Keyword.has_key?(opts, :port) do
      %{ state | port: Keyword.fetch!(opts, :port) }
    else
      state
    end

    state = if Keyword.has_key?(opts, :max_retries) do
      %{ state | max_retries: Keyword.fetch!(opts, :max_retries) }
    else
      state
    end

    state = if Keyword.has_key?(opts, :retry_interval) do
      %{ state | retry_interval: Keyword.fetch!(opts, :retry_interval) }
    else
      state
    end

    state = if Keyword.has_key?(opts, :retry_delay) do
      %{ state | retry_delay: Keyword.fetch!(opts, :retry_delay) }
    else
      state
    end
  end

end
