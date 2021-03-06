function initPage() {
  console.log( "initPage called" );
  // $(function () {
  //   $('[data-toggle="tooltip"]').tooltip();
  // });
  $.getJSON(myPrefix+'/api/receivableinvoices.json', function(data){
    $('#invoices_receivable > tbody').empty();
    for (var i = 0; i < data.length; i++) {
      var invoice_date;
      var paid_date;
      var due_date;
      var label='';
      if (data[i].invoice_date) { invoice_date=new Date(data[i].invoice_date); }
      if (data[i].due_date) { due_date=new Date(data[i].due_date); }
      if (data[i].paid_date && data[i].paid_date !== "" ) {
        var x=new Date(data[i].paid_date);
        paid_date=x.toLocaleDateString('it-IT');
        if (x <= due_date) { label='green'; } else { label='red'; }
      } else { paid_date='-'; }
      $('#invoices_receivable tbody').append('<tr><td><a href="'+myPrefix+'/api/receivableinvoice/'+data[i].invoice_id+'.pdf">'+data[i].invoice_id+'</a></td><td>'+invoice_date.toLocaleDateString('it-IT')+'</td><td>'+data[i].workorder+'</td><td>'+data[i].total+' €</td><td>'+data[i].vat+'</td><td>'+data[i].bank_transfer+' €</td><td>'+due_date.toLocaleDateString('it-IT')+'</td><td><span class="'+label+'">'+paid_date+'</span></td></tr>');
    }
  });
}

function refreshPage() {
  console.log( "refreshPage called" );
}