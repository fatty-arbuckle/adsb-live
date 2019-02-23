import $ from "jquery"
// import {socket} from "./socket"
import {Socket} from "phoenix"
import {messageSparkline} from "./message_sparkline"

// config for table cleanup
var markAsNoMessageInterval = 30 * 1000;
var deleteAircraftInterval = 120 * 1000;
// Updated by channel, used by graph
var rawMessageCount = 0;
var lastRawMessageCount = 0;
var aircraftMessageCount = 0;
var lastAircraftMessageCount = 0;

var socket_rawUpdate = new Socket("/socket", {params: {token: window.userToken}})
socket_rawUpdate.connect()


let channel = socket_rawUpdate.channel("aircraft:updates", {})
channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

channel.on("aircraft:updates", data => {
  // console.log(data);
  if ('raw' in data) {
    ++rawMessageCount;
    var rawMessages = $( "#raw_messages" )
    rawMessages
      .prepend( $( "<span class='text-muted text-monospace'>" + rawMessageCount + ": "+ data.raw + "</span>" ) );
    var ITEMS_TO_SHOW = 20;
    var items = rawMessages.children().slice(ITEMS_TO_SHOW).remove();
  }
})


messageSparkline("#raw_message_sparkline", "msg / second", 1, function(intervalInSeconds){
  var messageRate = (rawMessageCount - lastRawMessageCount) / intervalInSeconds;
  lastRawMessageCount = rawMessageCount;
  return messageRate;
});
