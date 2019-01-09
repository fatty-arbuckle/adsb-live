defmodule Aircraft do
  def update_topic, do: "aircraft:update"
  def raw_adsb_topic, do: "aircraft:raw_adsb"
  def channel, do: :aircraft_channel

  @enforce_keys [:icoa]
  defstruct [
    :icoa,
    :callsign,
    :longitude,
    :latitude,
    :altitude,
    :speed,
    :heading,
    :last_seen_time
  ]

end
