defmodule Aircraft.ParseAdsb do
  # http://woodair.net/SBS/Article/Barebones42_Socket_Data.htm
  # First two field already parsed off
  # @sessionId       0   # Database Session record number
  # @aircraftId      1   # Database Aircraft record number
  @hexId           2   # Aircraft Mode S hexadecimal code
  # @flightId        3   # Database Flight record number
  @dateGenerated   4   # Date message generated
  @timeGenerated   5   # Time message generated
  @dateLogged      6   # Date message logged
  @timeLogged      7   # Time message logged
  @callsign        8   # An eight digit flight ID
  @altitude        9   # Mode C altitude. Height relative to 1013.2mb (Flight Level)
  @groundSpeed    10   # Speed over ground (not indicated airspeed)
  @track          11   # Track of aircraft (not heading)
  @latitude       12   # Latitude
  @longitude      13   # Longitude
  @verticalRate   14   # Vertical Rate
  @squawk         15   # Assigned Mode A squawk code
  @alert          16   # Flag to indicate squawk has changed
  @emergency      17   # Flag to indicate emergency code has been set
  @spi            18   # Flag to indicate transponder Ident has been activated
  @isOnGround     19   # Flag to indicate ground squat switch is active

  # TRANSMISSION MESSAGE
  # Generated by the aircraft. There are eight different MSG types.
  def parse("MSG," <> data) do
    parse_msg(String.split(data, ","))
  end
  # SEL, ID, AIR, STA, CLK messages are ignored
  def parse(_ignored) do
    :not_supported
  end

  # ES Identification and Category
  defp parse_msg(["1" | fields]) do
    %Aircraft{
      icoa:           get_field(fields, @hexId),
      dateGenerated:  get_field(fields, @dateGenerated),
      timeGenerated:  get_field(fields, @timeGenerated),
      dateLogged:     get_field(fields, @dateLogged),
      timeLogged:     get_field(fields, @timeLogged),
      callsign:       get_field(fields, @callsign)
    }
  end
  # ES Airborne Position Message
  defp parse_msg(["3" | fields]) do
    %Aircraft{
      icoa:           get_field(fields, @hexId),
      dateGenerated:  get_field(fields, @dateGenerated),
      timeGenerated:  get_field(fields, @timeGenerated),
      dateLogged:     get_field(fields, @dateLogged),
      timeLogged:     get_field(fields, @timeLogged),
      longitude:      get_field(fields, @longitude) |> parse_float,
      latitude:       get_field(fields, @latitude) |> parse_float,
      altitude:       get_field(fields, @altitude) |> parse_integer,
      alert?:         get_field(fields, @alert) |> parse_boolean,
      emergency?:     get_field(fields, @emergency) |> parse_boolean,
      spi?:           get_field(fields, @spi) |> parse_boolean,
      isOnGround?:    get_field(fields, @isOnGround) |> parse_boolean
    }
  end
  # ES Airborne Velocity Message
  defp parse_msg(["4" | fields]) do
    %Aircraft{
      icoa:           get_field(fields, @hexId),
      dateGenerated:  get_field(fields, @dateGenerated),
      timeGenerated:  get_field(fields, @timeGenerated),
      dateLogged:     get_field(fields, @dateLogged),
      timeLogged:     get_field(fields, @timeLogged),
      speed:          get_field(fields, @groundSpeed) |> parse_integer,
      heading:        get_field(fields, @track) |> parse_integer,
      vertical:       get_field(fields, @verticalRate) |> parse_integer
    }
  end
  defp parse_msg([unknown | _fields]) do
    IO.inspect(unknown, label: "unknown message ID")
    :not_supported
  end

  defp get_field(fields, f) do
    String.trim(Enum.at(fields, f))
  end

 # # ES Surface Position Message
 # MSG,2
 #
 # MSG,3
 #
 # MSG,4
 #
 #  # Surveillance Alt Message
 # MSG,5
 #
 #  # Surveillance ID Message
 # MSG,6
 #
 #  # Air To Air Message
 # MSG,7
 #
 #  # All Call Reply
 # MSG,8

  # def parse(_ignored) do
  #   :not_supported
  # end

  defp parse_boolean("0"), do: False
  defp parse_boolean(_), do: True

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
