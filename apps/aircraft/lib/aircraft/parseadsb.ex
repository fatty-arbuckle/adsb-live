defmodule Aircraft.ParseAdsb do

  def parse("MSG,1," <> data) do
    tmp = String.split(data, ",")
    icoa = Enum.at(tmp,2)
    callsign = String.trim(Enum.at(tmp, 8))
    %Aircraft{
      icoa: icoa,
      callsign: callsign
    }
  end
  def parse("MSG,3," <> data) do
    tmp = String.split(data, ",")
    icoa = Enum.at(tmp,2)
    altitude = parse_integer(Enum.at(tmp, 9))
    lat = parse_float(Enum.at(tmp, 12))
    lon = parse_float(Enum.at(tmp, 13))
    %Aircraft{
      icoa: icoa,
      longitude: lon,
      latitude: lat,
      altitude: altitude
    }
  end
  def parse("MSG,4," <> data) do
    tmp = String.split(data, ",")
    icoa = Enum.at(tmp,2)
    speed = parse_integer(Enum.at(tmp, 10))
    heading = parse_integer(Enum.at(tmp, 11))
    %Aircraft{
      icoa: icoa,
      speed: speed,
      heading: heading
    }
  end
  def parse(_ignored) do
    :not_supported
  end

  defp parse_integer(s) do
    case Integer.parse(s) do
      {i, _} -> i
      :error -> nil
    end
  end

  defp parse_float(s) do
    case Float.parse(s) do
      {f, _} -> f
      :error -> nil
    end
  end

end
