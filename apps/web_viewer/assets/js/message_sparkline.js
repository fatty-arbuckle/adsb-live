import $ from "jquery"

export function messageSparkline(selector, label, intervalInSeconds, updateRate) {

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
    rateChild.text(rawMessageRate + " " + label)
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
