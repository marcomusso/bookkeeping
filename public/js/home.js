var InvoicesData;

function doGraph(element) {
  console.log('doGraph called on '+element);
  var w = $(element).width();
  var h = 500;
  var margin = {
    top: 20,
    bottom: 80,
    left: 80,
    right: 20
  };
  var width = w - margin.left - margin.right;
  var height = h - margin.top - margin.bottom;

  var xScale = d3.scale.ordinal()
               .domain(InvoicesData.map(function(entry){
                  return entry.invoice_id;
               }))
               .rangeBands([0, width]);

  var yScale = d3.scale.linear()
             .domain([0, d3.max(InvoicesData, function(d) { return d.total; })])
             .range([height, 0]);

  var xAxis = d3.svg.axis()
              .scale(xScale)
              .orient("bottom");
  var yAxis = d3.svg.axis()
              .scale(yScale)
              .orient("left");

  var yGridLines=d3.svg.axis()
                 .scale(yScale)
                 .tickSize(-width,0,0)
                 .tickFormat("")
                 .orient("left");

  var svg = d3.select(element)
      .append("svg")
      .attr("width", w)
      .attr("height", h);

  var chart = svg.append("g")
        .classed("display", true)
        .attr("transform", "translate("+margin.left+","+margin.top +")");

  var sort_btn = d3.select("#controls")
        .append("button")
        .classed("btn btn-sm btn-primary pull-right", true)
        .html("Sort data: ascending")
        .attr("state", "0");

  sort_btn.on("click", function(){
    var self=d3.select(this);
    var state=+self.attr("state");
    var txt="Sort data: ";
    if (state === 0) {
      state=1;
      txt+="descending";
    } else if (state === 1) {
      state=0;
      txt+="ascending";
    }
    self.attr("state", state);
    self.html(txt);
  });

  chart.append("g")
    .call(yGridLines)
    .classed("gridline", true)
    .attr("transform", "translate(0,0)");
  chart.selectAll(".bar")
    .data(InvoicesData)
    .enter()
    .append("rect")
    .classed("bar", true)
    .attr("x", function(d,i){
      return xScale(d.invoice_id);
    })
    .attr("y", function(d,i){
      return yScale(d.total);
    })
    .attr("width", function(d,i){
      return xScale.rangeBand()-1;
    })
    .attr("height", function(d,i){
      return height-yScale(d.total);
    });
  chart.selectAll(".bar-label")
    .data(InvoicesData)
    .enter()
    .append("text")
    .classed("bar-label", true)
    .attr("x", function(d,i){
      return xScale(d.invoice_id) + (xScale.rangeBand()/2);
    })
    .attr("dx", 0)
    .attr("y", function(d,i){
      return yScale(d.total);
    })
    .attr("dy", -6)
    .text(function(d,i){
       return d.total;
    });
  chart.append("g")
       .classed("x axis", true)
       .attr("transform","translate(0,"+height+")")
       .call(xAxis)
          .selectAll("text")
            .style("text-anchor", "end")
            .attr("dx", -8)
            .attr("dy", 8)
            .attr("transform", "translate(0,0) rotate(-45)");
  chart.append("g")
       .classed("y axis", true)
       .attr("transform","translate(0,0)")
       .call(yAxis);

  chart.select(".y.axis")
      .append("text")
      .attr("x", 0)
      .attr("y", 0)
      .style("text-anchor","middle")
      .attr("transform","translate(-60,"+height/2+") rotate(-90)")
      .text("Invoice amount (Euro)");

  chart.select(".x.axis")
      .append("text")
      .attr("x", 0)
      .attr("y", 0)
      .style("text-anchor","middle")
      .attr("transform","translate("+width/2+",80)")
      .text("Invoice id");
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