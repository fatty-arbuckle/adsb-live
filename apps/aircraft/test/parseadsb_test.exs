defmodule ParseTest do
  use ExUnit.Case

  # STA,,5,179,400AE7,10103,2008/11/28,14:58:51.153,2008/11/28,14:58:51.153,RM
  # MSG,4,5,211,4CA2D6,10057,2008/11/28,14:53:49.986,2008/11/28,14:58:51.153,,,408.3,146.4,,,64,,,,,
  # MSG,8,5,211,4CA2D6,10057,2008/11/28,14:53:50.391,2008/11/28,14:58:51.153,,,,,,,,,,,,0
  # MSG,4,5,211,4CA2D6,10057,2008/11/28,14:53:50.391,2008/11/28,14:58:51.153,,,408.3,146.4,,,64,,,,,
  # MSG,3,5,211,4CA2D6,10057,2008/11/28,14:53:50.594,2008/11/28,14:58:51.153,,37000,,,51.45735,-1.02826,,,0,0,0,0
  # MSG,8,5,812,ABBEE3,10095,2008/11/28,14:53:50.594,2008/11/28,14:58:51.153,,,,,,,,,,,,0
  # MSG,3,5,276,4010E9,10088,2008/11/28,14:53:49.986,2008/11/28,14:58:51.153,,28000,,,53.02551,-2.91389,,,0,0,0,0
  # MSG,4,5,276,4010E9,10088,2008/11/28,14:53:50.188,2008/11/28,14:58:51.153,,,459.4,20.2,,,64,,,,,
  # MSG,8,5,276,4010E9,10088,2008/11/28,14:53:50.594,2008/11/28,14:58:51.153,,,,,,,,,,,,0
  # MSG,3,5,276,4010E9,10088,2008/11/28,14:53:50.594,2008/11/28,14:58:51.153,,28000,,,53.02677,-2.91310,,,0,0,0,0
  # MSG,4,5,769,4CA2CB,10061,2008/11/28,14:53:50.188,2008/11/28,14:58:51.153,,,367.7,138.6,,,-2432,,,,,
  # MSG,8,5,769,4CA2CB,10061,2008/11/28,14:53:50.391,2008/11/28,14:58:51.153,,,,,,,,,,,,0

  test "MSG,1" do
    rawMessage = "MSG,1,111,11111,A44728,111111,2018/11/17,21:33:06.976,2018/11/17,21:33:06.938,JBU1616 ,,,,,,,,,,,0"
    expected = %Aircraft{
      icoa:           "A44728",
      dateGenerated:  "2018/11/17",
      timeGenerated:  "21:33:06.976",
      dateLogged:     "2018/11/17",
      timeLogged:     "21:33:06.938",
      callsign:       "JBU1616"
    }
    assert expected == Aircraft.ParseAdsb.parse(rawMessage)
  end

  test "MSG,3" do
    rawMessage = "MSG,3,,,AADFF1,,,,,,,40000,,,42.49749,-71.02463,,,0,0,0,0"
    expected = %Aircraft{
      icoa:           "AADFF1",
      dateGenerated:  "",
      timeGenerated:  "",
      dateLogged:     "",
      timeLogged:     "",
      longitude:      -71.02463,
      latitude:       42.49749,
      altitude:       40000,
      alert?:         False,
      emergency?:     False,
      spi?:           False,
      isOnGround?:    False
    }
    assert expected == Aircraft.ParseAdsb.parse(rawMessage)
  end

  test "MSG,4" do
    rawMessage = "MSG,4,,,A77C11,,,,,,,,397,251,,,0,,0,0,0,0"
    expected = %Aircraft{
      icoa:           "A77C11",
      dateGenerated:  "",
      timeGenerated:  "",
      dateLogged:     "",
      timeLogged:     "",
      speed:          397,
      heading:        251,
      vertical:       0,
    }
    assert expected == Aircraft.ParseAdsb.parse(rawMessage)
  end
end
