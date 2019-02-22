defmodule Aircraft do
  def update_topic, do: "aircraft:update"
  def raw_adsb_topic, do: "aircraft:raw_adsb"
  def channel, do: :aircraft_channel

  @enforce_keys [:icoa]
  defstruct [
    :icoa,
    :dateGenerated,
    :timeGenerated,
    :dateLogged,
    :timeLogged,
    :callsign,
    :longitude,
    :latitude,
    :altitude,
    :speed,
    :heading,
    :vertical,
    :squawk,
    :alert?,
    :emergency?,
    :spi?,
    :isOnGround?,
    :last_seen_time
  ]

end
