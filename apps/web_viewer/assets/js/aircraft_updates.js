import $ from "jquery"
import {socket} from "./socket"

// config for table cleanup
var markAsNoMessageInterval = 30 * 1000;
var deleteAircraftInterval = 120 * 1000;
// Updated by channel, used by graph
var rawMessageCount = 0;
// holds maps of icoa to timeouts
var deleteTimerMap = {};
// messages per icoa
var messagesPerIcoa = {};

let channel = socket.channel("aircraft:updates", {})
channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

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
  if ('raw' in data) {
    ++rawMessageCount;
    var rawMessages = $( "#raw_messages" )
    rawMessages
      .prepend( $( "<span class='text-muted text-monospace'>" + rawMessageCount + ": "+ data.raw + "</span>" ) );
    var ITEMS_TO_SHOW = 20;
    var items = rawMessages.children().slice(ITEMS_TO_SHOW).remove();
  } else {
    var aircraft = data.update
    var liveAircraftList = $( "#live-aircraft" )
    // var deadAircraftList = $( "#dead-aircraft" )
    var icoa = aircraft.icoa;
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


rawMessageSparkline("#raw_message_sparkline", 1);

function rawMessageSparkline(selector, rawMessageIntervalInSeconds) {

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
      .duration(rawMessageIntervalInSeconds * 1000)
      .ease(d3.easeLinear)
      .on("start", tick);


  var lastRawMessageCount = 0;
  function tick() {
    data.pop();
    data.shift();
    data.unshift(0);

    var rawMessageRate = (rawMessageCount - lastRawMessageCount) / rawMessageIntervalInSeconds;
    lastRawMessageCount = rawMessageCount;
    rateChild.text(rawMessageRate + " msg / second")
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
