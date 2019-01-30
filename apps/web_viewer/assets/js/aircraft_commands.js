import $ from "jquery"
import {socket} from "./socket"

// Now that you are connected, you can join channels with a topic:
let channelCommand = socket.channel("aircraft:command", {})
channelCommand.join()
  .receive("ok", resp => { console.log("Successfully joined command channel", resp) })
  .receive("error", resp => { console.log("Unable to join command channel", resp) })

channelCommand.on("phx_reply", function(data) {
  if ('status' in data.response) {
    var msg = "connected to " + data.response.status.address
    $("#connection-info").text(msg);
    toggleConnectionInfo($("#connection-info"), data.response.status.connected)
  } else {
    $("#connection-info").text("unknown connection status");
    toggleConnectionInfo($("#connection-info"), false)
  }
});

function toggleConnectionInfo(selector, bool) {
  if (bool) {
    selector.removeClass("text-warning");
    selector.addClass("text-success");
  } else {
    selector.removeClass("text-success");
    selector.addClass("text-warning");
  }
}

setInterval(function () {
  channelCommand.push("status", {})
}, 1000)
