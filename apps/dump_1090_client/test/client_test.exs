defmodule ClientTest do
  use ExUnit.Case, async: true

  test "that client connects and broadcasts messages" do
    Phoenix.PubSub.subscribe Aircraft.channel, Aircraft.raw_adsb_topic
    Phoenix.PubSub.subscribe Aircraft.channel, Aircraft.update_topic
    server = Task.async(fn ->
      {:ok, listener} = :gen_tcp.listen(30123, [packet: :line, active: false, reuseaddr: true])
      {:ok, socket} = :gen_tcp.accept(listener, 5000)
      :gen_tcp.send(socket, "MSG,1,111,11111,A44728,111111,2018/11/17,21:33:06.976,2018/11/17,21:33:06.938,JBU1616 ,,,,,,,,,,,0\n")
    end)
    Dump1090Client.Network.Client.start_link [host: "127.0.0.1", port: 30123]
    Task.await(server)
    assert_receive "MSG,1,111,11111,A44728,111111,2018/11/17,21:33:06.976,2018/11/17,21:33:06.938,JBU1616 ,,,,,,,,,,,0\n", 1000
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

end
