import $ from "jquery"
// import {socket} from "./socket"
import {Socket} from "phoenix"
import {messageSparkline} from "./message_sparkline"

// config for table cleanup
var markAsNoMessageInterval = 30 * 1000;
var deleteAircraftInterval = 120 * 1000;
// Updated by channel, used by graph
var aircraftMessageCount = {};
// holds maps of icoa to timeouts
var deleteTimerMap = {};
// messages per icoa
var messagesPerIcoa = {};

var socket_aircraftUpdate = new Socket("/socket", {params: {token: window.userToken}})
socket_aircraftUpdate.connect()


let channel = socket_aircraftUpdate.channel("aircraft:updates", {})
channel.join()
  .receive("ok", resp => { console.log("Joined aircraft updates successfully", resp) })
  .receive("error", resp => { console.log("Unable to join aircraft updates", resp) })

function removeAircraft(key) {
  $("#" + key).removeClass("table-dark");
  $("#" + key).addClass("table-danger");
  $("#" + key).detach().prependTo("#dead-aircraft");
}

function grayOutAircraft(key) {
  $("#" + key).addClass("table-dark");
  deleteTimerMap[key] = setTimeout(function(key1 = key) {
    removeAircraft(key1)
  }, deleteAircraftInterval);
}

channel.on("aircraft:updates", data => {
  // console.log(data)
  if ('update' in data) {
    var aircraft = data.update
    var liveAircraftList = $( "#live-aircraft" )
    // var deadAircraftList = $( "#dead-aircraft" )
    var icoa = aircraft.icoa;
    aircraftMessageCount[icoa] = 1;
    var icoaRow = $("#" + icoa)
    if (icoaRow.length == 0) {
      messagesPerIcoa[icoa] = 1;
      liveAircraftList.prepend(
        "<tr id='" + icoa + "'>" +
        "<th scope='row'>" + icoa + "</th>" +
        "<td id='callsign'>" + aircraft.callsign + "</td>" +
        "<td id='longitude'>" + aircraft.longitude + "</td>"  +
        "<td id='latitude'>" + aircraft.latitude + "</td>" +
        "<td id='altitude'>" + aircraft.altitude + "</td>" +
        "<td id='speed'>" + aircraft.speed + "</td>" +
        "<td id='heading'>" + aircraft.heading + "</td>" +
        "<td id='veritcal'>" + aircraft.vertical + "</td>" +
        // "<td id='ground?'>" + aircraft['isOnGround?'] + "</td>" +
        "<td id='messages'>" + messagesPerIcoa[icoa] + "</td>" +
        "</tr>"
      )
      deleteTimerMap[icoa] = setTimeout(function(key = icoa) {
        grayOutAircraft(key);
      }, markAsNoMessageInterval);
    } else {
      clearTimeout(deleteTimerMap[icoa]);
      deleteTimerMap[icoa] = setTimeout(function(key = icoa) {
        grayOutAircraft(key);
      }, markAsNoMessageInterval);

      icoaRow.removeClass("table-dark");
      messagesPerIcoa[icoa] = messagesPerIcoa[icoa] + 1;

      if (aircraft.callsign) {
        icoaRow.children('#callsign').text(aircraft.callsign)
      }
      if (aircraft.longitude) {
        icoaRow.children('#longitude').text(aircraft.longitude)
      }
      if (aircraft.latitude) {
        icoaRow.children('#latitude').text(aircraft.latitude)
      }
      if (aircraft.altitude) {
        icoaRow.children('#altitude').text(aircraft.altitude)
      }
      if (aircraft.speed) {
        icoaRow.children('#speed').text(aircraft.speed)
      }
      if (aircraft.heading) {
        icoaRow.children('#heading').text(aircraft.heading)
      }
      if (aircraft.vertical) {
        icoaRow.children('#vertical').text(aircraft.vertical)
      }
      // if (aircraft['isOnGround?']) {
      //   icoaRow.children('#ground?').text(aircraft['isOnGround?'])
      // }
      icoaRow.children('#messages').text(messagesPerIcoa[icoa])
    }
  } else if ('aircraft_registry' in data) {
    // TODO output registry data
    // console.log(data);
  }
})


messageSparkline("#aircraft_update_sparkline", "aircraft / second", 1, function(intervalInSeconds){
  var messageRate = (Object.keys(aircraftMessageCount).length) / intervalInSeconds;
  aircraftMessageCount = {}
  return messageRate;
});
