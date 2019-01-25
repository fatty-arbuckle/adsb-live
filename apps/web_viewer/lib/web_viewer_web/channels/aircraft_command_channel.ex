defmodule WebViewerWeb.AircraftCommandChannel do
  use WebViewerWeb, :channel

  def join("aircraft:command", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info(message, state) do
    IO.inspect(message, label: "command channel")
    {:noreply, state}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("status", _payload, socket) do
    {:reply, {:ok, %{status: Dump1090Client.status}}, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
