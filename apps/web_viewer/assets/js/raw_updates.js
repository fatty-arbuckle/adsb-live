import $ from "jquery"
// import {socket} from "./socket"
import {Socket} from "phoenix"

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


messageSparkline("#raw_message_sparkline", 1, function(intervalInSeconds){
  var messageRate = (rawMessageCount - lastRawMessageCount) / intervalInSeconds;
  lastRawMessageCount = rawMessageCount;
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
