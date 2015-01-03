function initPage() {
  console.log( "initPage called" );
  $.getJSON('/api/getreceivableinvoices.json', function(data){
    // console.log(data);
    $('#invoices_receivable > tbody').empty();
    for (var i = 0; i < data.length; i++) {
      $('#invoices_receivable tbody').append('<tr><td>'+data[i].invoice_id+'</td><td>'+data[i].invoice_date+'</td><td>'+data[i].workorder+'</td><td>'+data[i].total+'</td><td>'+data[i].due_date+'</td><td>'+data[i].paid_date+'</td>');
    }
  });

}

function refreshPage() {
  console.log( "refreshPage called" );
}