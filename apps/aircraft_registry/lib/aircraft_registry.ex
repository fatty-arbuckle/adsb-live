defmodule AircraftRegistry do
  @moduledoc """
  Documentation for AircraftRegistry.
  """

  defstruct [
    :icoa,
    :registrant,
    :registrant_type,
    :city,
    :state,
    :country,
    :aircraft_manufacturer,
    :aircraft_model,
    :aircraft_type,
    :aircraft_year,
    :aircraft_category,
    :engine_count,
    :seat_count,
    :weight,
    :speed,
    :engine_manufacturer,
    :engine_model,
    :engine_type,
    :power
  ]

  def lookup_icoa(icoa) do
    query = """
      SELECT
          master.year_mfr
        , master.type_registrant
        , master.name
        , master.city
        , master.state
        , master.country
        , master.mode_s_code_hex
        , aircraft_reference.mfr
        , aircraft_reference.model
        , aircraft_reference.type_acft
        , aircraft_reference.ac_cat
        , aircraft_reference.no_eng
        , aircraft_reference.no_seats
        , aircraft_reference.ac_weight
        , aircraft_reference.speed
        , engine.mfr as engine_mfr
        , engine.model as engine_model
        , engine.type as engine_type
        , engine.horsepower
        , engine.thrust
      FROM master
        LEFT OUTER JOIN aircraft_reference ON (master.mfr_mdl_code = aircraft_reference.code)
        LEFT OUTER JOIN engine ON (master.eng_mfr_mdl = engine.code)
      WHERE mode_s_code_hex = '#{String.upcase(icoa)}';
    """

    query = Postgrex.query!(:AircraftRegistry, query, [])
    case query.num_rows do
      0 ->
        {:error, :not_found}
      1 ->
        convert_to_struct(query)
      _ ->
        IO.inspect(query, label: "TOO MANY MATCHES?")
        { :error, :too_many_matches }
    end
  end

  defp convert_to_struct(query) do
    raw = Enum.zip(query.columns, Enum.at(query.rows, 0)) |> Enum.into(%{})
    %AircraftRegistry{
      icoa:                   String.trim(raw["mode_s_code_hex"]),
      registrant:             String.trim(raw["name"]),
      registrant_type:        lookup_registrant_type(String.trim(raw["type_registrant"])),
      city:                   String.trim(raw["city"]),
      state:                  String.trim(raw["state"]),
      country:                String.trim(raw["country"]),
      aircraft_manufacturer:  String.trim(raw["mfr"]),
      aircraft_model:         String.trim(raw["model"]),
      aircraft_type:          lookup_aircraft_type(String.trim(raw["type_acft"])),
      aircraft_year:          String.trim(raw["year_mfr"]),
      aircraft_category:      lookup_category(String.trim(raw["ac_cat"])),
      engine_count:           String.trim(raw["no_eng"]),
      seat_count:             String.trim(raw["no_seats"]),
      weight:                 String.trim(raw["ac_weight"]),
      speed:                  String.trim(raw["speed"]),
      engine_manufacturer:    String.trim(raw["engine_mfr"]),
      engine_model:           String.trim(raw["engine_model"]),
      engine_type:            lookup_engine_type(String.trim(raw["engine_type"])),
      power:                  lookup_power(raw)
    }
  end

  defp lookup_power(raw) do
    case String.trim(raw["engine_type"]) do
      type when type in [ "1", "2", "3", "7", "8" ] ->
        String.trim(raw["horsepower"])  <> " horsepower"
      type when type in [ "4", "5", "6" ] ->
        String.trim(raw["thrust"]) <> " thrust"
      value ->
        "unknown #{value}"
    end
  end


  defp lookup_registrant_type(type) do
    case type do
      "1" -> "Individual"
      "2" -> "Partnership"
      "3" -> "Corporation"
      "4" -> "Co-Owned"
      "5" -> "Government"
      "8" -> "Non Citizen Corporation"
      "9" -> "Non Citizen Co-Owned"
      _ -> "unknown '#{type}'"
    end
  end

  defp lookup_aircraft_type(type) do
    case type do
      "1" -> "Glider"
      "2" -> "Balloon"
      "3" -> "Blimp/Dirigible"
      "4" -> "Fixed wing single engine"
      "5" -> "Fixed wing multi engine"
      "6" -> "Rotorcraft"
      "7" -> "Weight-shift-control"
      "8" -> "Powered Parachute"
      "9" -> "Gyroplane"
      "H" -> "Hybrid Lift"
      "O" -> "Other"
      _ -> "unknown '#{type}'"
    end
  end

  defp lookup_category(category) do
    case category do
      "1" -> "Land"
      "2" -> "Sea"
      "3" -> "Amphibian"
      _ -> "unknown '#{category}'"
    end
  end

  defp lookup_engine_type(type) do
    case type do
      "0" -> "None"
      "1" -> "Reciprocating"
      "2" -> "Turbo-prop"
      "3" -> "Turbo-shaft"
      "4" -> "Turbo-jet"
      "5" -> "Turbo-fan"
      "6" -> "Ramjet"
      "7" -> "2 Cycle"
      "8" -> "4 Cycle"
      "9" -> "Unknown"
      "10" -> "Electric"
      "11" -> "Rotary"
      _ -> "unknown #{type}"
    end
  end
end
