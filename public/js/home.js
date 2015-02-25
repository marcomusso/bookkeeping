var InvoicesData;
var xScale;
var yScale;
var xAxis;
var yAxis;
var yGridlines;
var svg;
var chart;
var sort_btn;
var margin = {
  top: 20,
  bottom: 80,
  left: 80,
  right: 20
};
var width;  // before margins
var w;      // after margins
var height; // before margins
var h=500;  // after margins
var tip;    // tooltip

function drawAxis(params){
  if(params.initialize === true){
    //Draw the gridlines
    this.append("g")
      .call(params.gridlines)
      .classed("gridline", true)
      .attr("transform", "translate(0,0)");

    //This is the x axis
    this.append("g")
      .classed("x axis", true)
      .attr("transform", "translate(0," + height + ")")
      .call(params.axis.x)
        .selectAll("text")
          .classed("x-axis-label", true)
          .style("text-anchor", "end")
          .attr("dx", -8)
          .attr("dy", 8)
          .attr("transform", "translate(0,0) rotate(-45)");

    //This is the y axis
    this.append("g")
      .classed("y axis", true)
      .attr("transform", "translate(0,0)")
      .call(params.axis.y);

    //This is the y label
    this.select(".y.axis")
      .append("text")
      .attr("x", 0)
      .attr("y", 0)
      .style("text-anchor", "middle")
      .attr("transform","translate(-60,"+height/2+") rotate(-90)")
      .text(i18n.t("Invoice amount"));

    //This is the x label
    this.select(".x.axis")
      .append("text")
      .attr("x", 0)
      .attr("y", 0)
      .style("text-anchor", "middle")
      .attr("transform", "translate(" + width/2 + ",80)")
      .text(i18n.t("Invoice id"));

  } else if(params.initialize === false){
    //Update info
    this.selectAll("g.x.axis")
      .transition()
      .duration(500)
      .ease("bounce")
      .delay(500)
      .call(params.axis.x);
    this.selectAll(".x-axis-label")
      .style("text-anchor", "end")
      .attr("dx", -8)
      .attr("dy", 8)
      .attr("transform", "translate(0,0) rotate(-45)");
    this.selectAll("g.y.axis")
      .transition()
      .duration(500)
      .ease("bounce")
      .delay(500)
      .call(params.axis.y);
  }
}
function plot(params) {
  xScale.domain(params.data.map(function(entry){
    return entry.invoice_id;
  }));
  yScale.domain([0, d3.max(params.data, function(d) {
    return d.total;
  })]);

  //Draw the axes and axes labels
  drawAxis.call(this, params);

  // enter() - bound data to obj
    // BARS
    this.selectAll(".bar")
      .data(params.data)
      .enter()
        .append("rect")
        .classed("bar", true)
        .on('mouseover', tip.show)
        .on('mouseout', tip.hide);
    // BAR LABELS
    this.selectAll(".bar-label")
      .data(params.data)
      .enter()
      .append("text")
      .classed("bar-label", true);
  // update  - update bars and labels
    // BARS
    this.selectAll(".bar ")
        // data already bounded and .update is implicit
        .attr("x", function(d,i){
          return xScale(d.invoice_id);
        })
        .attr("y", function(d,i){
          return yScale(d.total);
        })
        .attr("width", function(d,i){
          return xScale.rangeBand()-2;
        })
        .attr("height", function(d,i){
          return height-yScale(d.total);
        });
    // BAR LABELS
    this.selectAll(".bar-label")
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
  // exit()  - remove unnecessary obj not bounded to data (in any)
    this.selectAll(".bar")
      .data(params.data)
      .exit()
      .remove();
    this.selectAll(".bar-label")
      .data(params.data)
      .exit()
      .remove();
}
var ascending = function(a,b) {
  if ( a.invoice_date < b.invoice_date )
    return -1;
  if ( a.invoice_date > b.invoice_date )
    return 1;
  return 0;
};
var descending = function(a,b) {
  if ( a.invoice_date > b.invoice_date )
    return -1;
  if ( a.invoice_date < b.invoice_date )
    return 1;
  return 0;
};

function initPage() {
  console.log( "initPage called" );

  w = $("#graphcontainer").width();
  width = w - margin.left - margin.right;
  height = h - margin.top - margin.bottom;

  tip = d3.tip()
    .attr('class', 'd3-tip')
    .html(function(d) {
      var pd=new Date(d.paid_date);
      if (d.paid_date==='') { pd_string='-'; } else { pd_string=pd.toLocaleDateString('it-IT'); }
      return i18n.t("Invoice id")+': '+d.invoice_id+'<br>'+i18n.t("Workorder")+': '+d.workorder+'<br>'+i18n.t("Paid on")+': '+pd_string;
    });

  if (mySessionData['email'] !== '') {
    $.getJSON(myPrefix+'/api/receivableinvoices.json', function(data){
      InvoicesData=data;
      InvoicesData.sort(ascending);

      // Interactivity
      sort_btn = d3.select("#controls")
            .append("button")
            .classed("btn btn-sm btn-primary pull-right", true)
            .html(i18n.t("Sort by invoice date")+': '+i18n.t('descending'))
            .attr("state", "0");
      sort_btn.on("click", function(){
        var self=d3.select(this);
        var state=+self.attr("state");
        var txt=i18n.t("Sort by invoice date")+": ";
        if (state === 0) {
          InvoicesData.sort(ascending);
          state=1;
          txt+=i18n.t("descending");
        } else if (state === 1) {
          InvoicesData.sort(descending);
          state=0;
          txt+=i18n.t("ascending");
        }
        console.log(InvoicesData);
        self.attr("state", state);
        self.html(txt);
        plot.call(chart, {
          data: InvoicesData,
          axis:{
            x: xAxis,
            y: yAxis
          },
          gridlines: yGridlines,
          initialize: false
        });
      });

      xScale = d3.scale.ordinal()
                   .domain(InvoicesData.map(function(entry){
                      return entry.invoice_id;
                   }))
                   .rangeBands([0, width]);
      yScale = d3.scale.linear()
                 .domain([0, d3.max(InvoicesData, function(d) { return d.total; })])
                 .range([height, 0]);
      xAxis = d3.svg.axis()
                  .scale(xScale)
                  .orient("bottom");
      yAxis = d3.svg.axis()
                  .scale(yScale)
                  .orient("left");
      yGridlines=d3.svg.axis()
                     .scale(yScale)
                     .tickSize(-width,0,0)
                     .tickFormat("")
                     .orient("left");
      svg = d3.select("#graphcontainer")
          .append("svg")
          .attr("id", "chart")
          .attr("width", w)
          .attr("height", h).call(tip);
      chart = svg.append("g")
            .classed("display", true)
            .attr("transform", "translate("+margin.left+","+margin.top +")");

      // GRAPH IT!
      plot.call(chart, {
        data: data,
        axis:{
          x: xAxis,
          y: yAxis
        },
        gridlines: yGridlines,
        initialize: true
      });
    });
  }
}

function refreshPage() {
  console.log( "refreshPage called" );
}