function initPage() {
  console.log( "initPage called" );
  $.getJSON('/api/getreceivableinvoices.json', function(data){
    console.log(data);
    $('#invoices_receivable > tbody').empty();
    for (var id in data) {
      $('#invoices_receivable tbody').append('<tr><td>'+id+'</td><td>'+data[id].invoice_date+'</td><td>'+data[id].workorder+'</td><td>'+data[id].total+'</td><td>'+data[id].due_date+'</td><td>'+data[id].paid_date+'</td>');
    }
  });

}

function refreshPage() {
  console.log( "refreshPage called" );
}