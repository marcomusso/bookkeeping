var myReceivableInvoice={};
  // receivable invoice fields:
    // "invoice_date": new Date("2014-12-28T00:00:00+0100"),
    // "invoice_id": "0012-14",
    // "workorder": "SAMPLE workorder (you can delete this entire obj)",
    // "units": 17,
    // "cost_per_unit": 300,
    // "resource": "Resource/person name",
    // "notes": "",
    // "total": "5100,00",
    // "vat": "22,00%",
    // "bank_transfer": "5100,00",
    // "due_date": new Date("2015-01-31T00:00:00+0100"),
    // "paid_date": ""

var myPayableInvoice={};
   // payable invoice fields:
     // "invoice_date": new Date("2014-10-28T00:00:00+0100"),
     // "invoice_id": "347A382",
     // "supplier": "SAMPLE payable supplier",
     // "notes": "Some note on this invoice",
     // "total": "5100,00",
     // "due_date": new Date("2014-12-31T00:00:00+0100"),
     // "paid_date": ""

function validateReceivableInvoiceAndSave() {
  console.log('validateInvoiceAndSave called.');

  // TODO if all is ok close modal
  $('#addReceivableInvoiceModal').modal('hide');
}

function validatePayableInvoiceAndSave() {
  console.log('validatePayableInvoiceAndSave called.');

  // TODO if all is ok close modal
  $('#addPayableInvoiceModal').modal('hide');
}

function initPage() {
  console.log( "initPage called" );
  $('.btn').on('click', function() {
    console.log($(this).attr('id')+' clicked.');
    switch($(this).attr('id')) {
      case 'addReceivableInvoice': $('#addReceivableInvoiceModal').modal('show');
                                   break;
      case 'addPayableInvoice': $('#addPayableInvoiceModal').modal('show');
                                   break;
      case 'saveReceivableInvoice': validateReceivableInvoiceAndSave();
                          break;
      case 'savePayableInvoice': validatePayableInvoiceAndSave();
                          break;
      default: console.log('Button '+$(this).attr('id')+' has no handler!');
               break;
    }
  });

  $.getJSON(myPrefix+'/api/receivableinvoices.json', function(data){
    $('#receivableInvoicesTable > tbody').empty();
    for (var i = 0; i < data.length; i++) {
      var invoice_date;
      var paid_date;
      var due_date;
      var file;
      var label='';
      if (data[i].invoice_date) { invoice_date=new Date(data[i].invoice_date); }
      if (data[i].due_date) { due_date=new Date(data[i].due_date); }
      if (data[i].paid_date && data[i].paid_date !== "" ) {
        var x=new Date(data[i].paid_date);
        paid_date=x.toLocaleDateString('it-IT');
        if (x <= due_date) { label='green'; } else { label='red'; }
      } else { paid_date='-'; }
      $('#receivableInvoicesTable tbody').append('<tr><td><a href="'+myPrefix+'/api/receivableinvoice/'+data[i].invoice_id+'.pdf">'+data[i].invoice_id+'</a></td><td>'+invoice_date.toLocaleDateString('it-IT')+'</td><td>'+data[i].workorder+'</td><td>'+data[i].total+' €</td><td>'+data[i].vat+'</td><td>'+data[i].bank_transfer+' €</td><td>'+due_date.toLocaleDateString('it-IT')+'</td><td><span class="'+label+'">'+paid_date+'</span></td><td><button id="editReceivableInvoice" invoice_id="'+data[i].invoice_id+'" class="btn btn-xs btn-primary"><i class="fa fa-pencil"></i></button></td></tr>');
    }
    $('#receivableInvoicesCount').html(data.length);
  });

  $.getJSON(myPrefix+'/api/payableinvoices.json', function(data){
    $('#payableInvoicesTable > tbody').empty();
    for (var i = 0; i < data.length; i++) {
      var invoice_date;
      var paid_date;
      var due_date;
      var label='red';
      if (data[i].invoice_date) { invoice_date=new Date(data[i].invoice_date); }
      if (data[i].due_date) { due_date=new Date(data[i].due_date); }
      if (data[i].paid_date !== "" ) { var x=new Date(data[i].paid_date); paid_date=x.toLocaleDateString('it-IT'); } else { paid_date='-'; }
      $('#payableInvoicesTable tbody').append('<tr><td><a href="'+myPrefix+'/api/payableinvoice/'+data[i].invoice_id+'.pdf">'+data[i].invoice_id+'</a></td><td>'+invoice_date.toLocaleDateString('it-IT')+'</td><td>'+data[i].workorder+'</td><td>'+data[i].total+' €</td><td>'+data[i].vat+'</td><td>'+data[i].bank_transfer+' €</td><td>'+due_date.toLocaleDateString('it-IT')+'</td><td class="'+label+'">'+paid_date+'</td><td><i class="fa fa-arrow-up"></i></td></tr>');
    }
    $('#payableInvoicesCount').html(data.length);
  });
}

function refreshPage() {
  console.log( "refreshPage called" );
}
