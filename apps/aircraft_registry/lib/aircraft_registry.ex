defmodule AircraftRegistry do
  @moduledoc """
  Documentation for AircraftRegistry.
  """

  def lookup_icoa(icoa) do
    query = "SELECT *"
      <> " FROM master"
      <> " WHERE mode_s_code_hex = '#{String.upcase(icoa)}';"
    IO.inspect(query)

    Postgrex.query!(:AircraftRegistry, query, [])
  end
end
