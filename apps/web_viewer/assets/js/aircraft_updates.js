import $ from "jquery"
// import {socket} from "./socket"
import {Socket} from "phoenix"

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
      icoaRow.children('#messages').text(messagesPerIcoa[icoa])
    }
  }
})


messageSparkline("#aircraft_update_sparkline", 1, function(intervalInSeconds){
  var messageRate = (Object.keys(aircraftMessageCount).length) / intervalInSeconds;
  aircraftMessageCount = {}
  return messageRate;
});




function messageSparkline(selector, intervalInSeconds, updateRate) {

  var sparklineChild = $(selector).children("#sparkline");
  var rateChild = $(selector).children("#rate");

  var svgHeight = $(selector)[0].clientHeight;
  var svgWidth = sparklineChild[0].clientWidth;

  var historyInSeconds = 60;
  var random = d3.randomNormal(0, 0);
  var data = d3.range(historyInSeconds).map(random);

  var svg = d3.select(selector + " #sparkline")
    .append("svg")
    .classed("sparkline", true)
    .classed("sparkline-svg", true)
    .attr("width", svgWidth)
    .attr("height", svgHeight);

  var margin = {top: 0, right: 0, bottom: 10, left: 0};
  var width = +svg.attr("width") - margin.left - margin.right;
  var height = +svg.attr("height") - margin.top - margin.bottom;
  var g = svg
    .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");
  var x = d3.scaleLinear()
    .domain([1, historyInSeconds-2])
    .range([0, width]);
  var y = d3.scaleLinear()
    .domain([0, 1])
    .range([height, 0]);
  var line = d3.line()
    .curve(d3.curveBasis)
    .x(function(d, i) { return x(i); })
    .y(function(d, i) { return y(d); });
  g.append("g")
    .attr("class", "axis axis--x")
    .attr("transform", "translate(0," + y(0) + ")")
    .call(d3.axisBottom(x).tickValues([]).tickSize(0));
  g.append("g")
    .append("path")
      .datum(data)
      .attr("class", "line")
    .transition()
      .duration(intervalInSeconds * 1000)
      .ease(d3.easeLinear)
      .on("start", tick);

  function tick() {
    data.pop();
    data.shift();
    data.unshift(0);

    var rawMessageRate = updateRate(intervalInSeconds);
    rateChild.text(rawMessageRate + " aircraft / second")
    data.push(rawMessageRate);

    data.push(0);

    y = d3.scaleLinear()
      .domain([0, d3.max(data)])
      .range([height, 0]);

    // Redraw the line.
    d3.select(this)
      .attr("d", line)
      .attr("transform", null);
    // Slide it to the left.
    d3.active(this)
      .attr("transform", "translate(" + x(0) + ",0)")
      .transition()
      .on("start", tick);
      // Pop the old data point off the front.
      data.shift();
    }
}
