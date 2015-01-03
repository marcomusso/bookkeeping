var InvoicesData;

function doGraph(element) {
  console.log('doGraph called on '+element);
  var w = $(element).width();
  var h = 1800;
  var margin = {
    top: 58,
    bottom: 100,
    left: 80,
    right: 40
  };
  var width = w - margin.left - margin.right;
  var height = h - margin.top - margin.bottom;

  var xScale = d3.scale.linear()
             .domain([0, d3.max(InvoicesData, function(d) { return d.total; })])
             .range([0, width]);

  var yScale = d3.scale.linear()
             .domain([0, InvoicesData.length])
             .range([0, height]);

  var svg = d3.select(element)
      .append("svg")
      .attr("width", w)
      .attr("height", h);

  var chart = svg.append("g")
        .classed("display", true)
        .attr("transform", "translate("+margin.left+","+margin.top +")");

  chart.selectAll(".bar")
    .data(InvoicesData)
    .enter()
    .append("rect")
    .classed("bar", true)
    .attr("x", 0)
    .attr("y", function(d,i){
      return yScale(i);
    })
    .attr("width", function(d,i){
      return xScale(d.total);
    })
    .attr("height", function(d,i){
      return yScale(1)-1;
    });
  chart.selectAll(".bar-label")
    .data(InvoicesData)
    .enter()
    .append("text")
    .classed("bar-label", true)
    .attr("x", function(d,i){
      return xScale(d.total);
    })
    .attr("dx", -4)
    .attr("y", function(d,i){
      return yScale(i);
    })
    .attr("dy", function(d,i){
      return yScale(1)/2+3;
    })
    .text(function(d,i){
       return d.total;
    });
}

function initPage() {
  console.log( "initPage called" );
  $.getJSON('/api/getreceivableinvoices.json', function(data){
    InvoicesData=data;
    doGraph('#summarygraph');
  });
}

function refreshPage() {
  console.log( "refreshPage called" );
}