defmodule WebViewerWeb.AircraftUpdatesChannel do
  use WebViewerWeb, :channel
  require Logger

  def join("aircraft:updates", payload, socket) do
    if authorized?(payload) do
      Phoenix.PubSub.subscribe Aircraft.channel, Aircraft.raw_adsb_topic
      Phoenix.PubSub.subscribe Aircraft.channel, Aircraft.update_topic
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info(message, state) do
    case message do
      {:raw, raw_message} ->
        WebViewerWeb.Endpoint.broadcast!("aircraft:updates", "aircraft:updates", %{raw: raw_message})
      {:update, aircraft} ->
        WebViewerWeb.Endpoint.broadcast!(
          "aircraft:updates",
          "aircraft:updates",
          %{update: aircraft}
        )
        case AircraftRegistry.lookup_icoa aircraft.icoa do
          {:error, error} ->
            IO.inspect(error, label: "registry lookup error for #{aircraft.icoa}")
          registry ->
            WebViewerWeb.Endpoint.broadcast!(
              "aircraft:updates",
              "aircraft:updates",
              %{aircraft_registry: registry}
            )
        end
        nil
    end
    {:noreply, state}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (aircraft:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
