defmodule Dump1090Client.Network.ClientTest do
  use ExUnit.Case, async: true

  test "client processing" do
    Phoenix.PubSub.subscribe Aircraft.channel, Aircraft.raw_adsb_topic
    Phoenix.PubSub.subscribe Aircraft.channel, Aircraft.update_topic

    Kernel.send(
      GenServer.whereis(Dump1090Client.Network.Client),
      {:tcp, nil, ["MSG,1,111,11111,A44728,111111,2018/11/17,21:33:06.976,2018/11/17,21:33:06.938,JBU1616 ,,,,,,,,,,,0\n"]}
    )

    assert_receive "MSG,1,111,11111,A44728,111111,2018/11/17,21:33:06.976,2018/11/17,21:33:06.938,JBU1616 ,,,,,,,,,,,0\n", 100
    assert_receive %Aircraft{
      altitude: nil,
      callsign: "JBU1616",
      heading: nil,
      icoa: "A44728",
      last_seen_time: nil,
      latitude: nil,
      longitude: nil,
      speed: nil
    }, 100
  end

  test "dump1090 client behavior" do
    # {:ok, sock} = :gen_tcp.listen(30003, [])
    # {:ok, socket} = :gen_tcp.accept(sock)
    # {:ok, data} = :gen_tcp.recv socket, 1024
    # IO.inspect(data, label: "data")
  end
end
