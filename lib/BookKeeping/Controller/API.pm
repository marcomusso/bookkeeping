package BookKeeping::Controller::API;

use Mojo::Base 'Mojolicious::Controller';
use Mojo::UserAgent;
use Mojo::IOLoop;
use Data::Dumper;
use POSIX qw(strftime locale_h);
use locale;
use DateTime;

# render static docs
sub docs {
  my $self = shift;
  $self->render('api/docs');
}

=head1 BookKeeping API

  http://<URL>/api/<method>/<params...>

  http://<URL>/api/...

Method list:
=cut

#########################################################################
# Private APIs
#########################################################################

=head2 getSession

Returns the session data to the caller as a JSON obj.

  # curl http://<URL>/api/getsession.json

=cut
sub getSession {
  my $self=shift;
  my $log=$self->api_log;
  my $log_level=$self->log_level;

  #  my ($sec,$min,$hour,$day,$month,$year) = (localtime(time-60*60*24))[0,1,2,3,4,5];
  # my $startlocale="$day/".($month+1)."/".($year+1900)." ".sprintf("%2d",$hour).":".sprintf("%2d",$min);
  # ($sec,$min,$hour,$day,$month,$year) = (localtime(time))[0,1,2,3,4,5];
  # my $endlocale="$day/".($month+1)."/".($year+1900)." ".sprintf("%2d",$hour).":".sprintf("%2d",$min);

  my %defaults=('theme'       => 'default',
                'email'       => '',
                'startepoch'  => time-60*60*24*365, # now - 1year
                'endepoch'    => time,             # now
                'timerange'   => 2
               );

  my $rua=$self->req->headers->user_agent;
  my $ip=$self->tx->remote_address;
  if ($log_level>0) {
    $self->api_log->debug("BookKeeping::Controller::API::getSession | Request by $rua @ $ip");
  }

  # se non ci sono valori validi usare i valori predefiniti di %defaults
    foreach my $key ( keys %defaults ) {
      if (!defined $self->session->{$key} or $self->session->{$key} eq '') {
        $self->session->{$key}=$defaults{$key};
      }
    }

  if ($log_level>1) { $self->api_log->debug("BookKeeping::Controller::API::getSession | Session: ".Dumper($self->session)); }

  $self->respond_to(
    json => { json => $self->session },
  );
}

=head2 setSession

  /api/setSession.json

TBW

=cut
sub setSession {
  my $self=shift;
  my $log=$self->api_log;
  my $log_level=2;

  my $rua=$self->req->headers->user_agent;
  my $ip=$self->tx->remote_address;
  if ($log_level>0) {
    $self->api_log->debug("BookKeeping::Controller::API::setSession | Request by $rua @ $ip");
  }

  my $params = $self->req->json;

  # store known parameters in session!
  $self->session->{startepoch} = $params->{'startepoch'};
  $self->session->{endepoch}   = $params->{'endepoch'};
  $self->session->{timerange}  = $params->{'timerange'};
  $self->session->{username}   = $params->{'username'};;
  $self->session->{theme}      = $params->{'theme'};

  # my ($sec,$min,$hour,$day,$month,$year) = (localtime($params->{'startepoch'}))[0,1,2,3,4,5];
  # my $startlocale="$day/".($month+1)."/".($year+1900)." ".sprintf("%d",$hour).":".sprintf("%02d",$min);
  # ($sec,$min,$hour,$day,$month,$year) = (localtime($params->{'endepoch'}))[0,1,2,3,4,5];
  # my $endlocale="$day/".($month+1)."/".($year+1900)." ".sprintf("%d",$hour).":".sprintf("%02d",$min);

  # $self->session->{startlocale} = $startlocale;
  # $self->session->{endlocale}   = $endlocale;

  if ($log_level>1) { $self->api_log->debug("BookKeeping::Controller::API::setSession | Session: ".Dumper($self->session)); }

  $self->respond_to(
    json => { json => { status => 'OK'} },
    txt  => { text => 'OK' }
  );
}

=head2 getReceivableInvoices

  /api/getReceivableInvoices.json

TBW

Returns an array of json.

=cut
sub getReceivableInvoices {
  my $self=shift;
  my $db=$self->db;
  my $log=$self->api_log;
  my $log_level=2;

  my $startdate = DateTime->from_epoch(
    epoch => $self->session->{'startepoch'}
  );
  my $enddate = DateTime->from_epoch(
    epoch => $self->session->{'endepoch'}
  );

  my $text_data="invoice_id,workorder,invoice_date,total,due_date,paid_date\n";
  my $sep=';';
  my @invoicesArray=();
  my %invoice;
  my %dt;

  my $rua=$self->req->headers->user_agent;
  my $ip=$self->tx->remote_address;
  if ($log_level>0) {
    $self->api_log->debug("BookKeeping::Controller::API::getReceivableInvoices | Request by $rua @ $ip");
  }

  my $invoices=$db->get_collection('invoices_receivable');
  my $all_invoices=$invoices->find({'invoice_date' => { '$gte' => $startdate, '$lte' => $enddate } });

  # { "_id" : ObjectId("5493f5c2f0ef319ba6f7a385"), "invoice_date" : "31/12/2011", "invoice_id" : "0020-11", "workorder" : "Finsoft/SPIMI2011", "units" : 19, "cost_per_unit" : 290, "resource" : "Musso", "notes" : "pagata nel 2012", "total" : "5510,00", "vat" : "21,00%", "bank_transfer" : "5.565,10", "due_date" : "10/02/2012", "paid_date" : "10/02/2012" }

  while (my $inv = $all_invoices->next) {
    # JSON array
      # my $datestring=$inv->{'invoice_date'}->day.'/'.$inv->{'invoice_date'}->month.'/'.$inv->{'invoice_date'}->year;
      # $inv->{'invoice_date'}=$datestring;
      # $datestring=$inv->{'due_date'}->day.'/'.$inv->{'due_date'}->month.'/'.$inv->{'due_date'}->year;
      # $inv->{'due_date'}=$datestring;
      # $datestring=$inv->{'paid_date'}->day.'/'.$inv->{'paid_date'}->month.'/'.$inv->{'paid_date'}->year;
      # $inv->{'paid_date'}=$datestring;
      push @invoicesArray, $inv;
    # CSV data
      $text_data.=$inv->{'invoice_id'}.$sep.
                  $inv->{'workorder'}.$sep.
                  $inv->{'invoice_date'}.$sep.
                  $inv->{'total'}.$sep.
                  $inv->{'bank_transfer'}.$sep.
                  $inv->{'due_date'}.$sep.
                  $inv->{'paid_date'}.
                  "\n";
  }

  # TODO handle .dt return format

  # my $totalRecords=0;
  # if (@$data == 0) {
  #   push @{$hash{'aaData'}}, ['','No data found',''];
  # } else {
  #   foreach my $row (@$data) {
  #     $text_data.="\"@$row[0]\",\"@$row[1]\",\"@$row[2]\"\n";
  #     push @{$hash{'aaData'}}, $row;
  #     $totalRecords+=1;
  #   }
  # }
  # push @{$hash{'iTotalRecords'}}, $totalRecords;
  # push @{$hash{'iTotalDisplayRecords'}}, $totalRecords;

  $self->respond_to(
    json => { json => \@invoicesArray },
    csv  => { text => $text_data },
    # TODO datatable format
    # dt => { json => \%dt }
  );
}

sub getPayableInvoices {
  my $self=shift;
  my $db=$self->db;
  my $log=$self->api_log;
  my $log_level=2;

  my $rua=$self->req->headers->user_agent;
  my $ip=$self->tx->remote_address;
  if ($log_level>0) {
    $self->api_log->debug("BookKeeping::Controller::API::getPayableInvoices | Request by $rua @ $ip");
  }


}

=head2 putReceivableInvoice

  /api/invoice.json

TBW

=cut
sub putReceivableInvoice {
  my $self  = shift;
  my $log_level = 2;
  my $status='OK';
  my %newInvoice;

  my $rua=$self->req->headers->user_agent;
  my $ip=$self->tx->remote_address;
  if ($log_level>0) {
    $self->api_log->debug("BookKeeping::Controller::API::putReceivableInvoice | Request by $rua @ $ip");
  }

  my $params = $self->req->json;
  # {
  #   "_id": ObjectId("549d98c1f286ef746073cdfa"),
  #   "invoice_date": new Date("2011-01-31T01:00:00+0100"),
  #   "invoice_id": "0003-11",
  #   "workorder": "IDM 2009",
  #   "units": 4,
  #   "cost_per_unit": 300,
  #   "resource": "Musso",
  #   "notes": "4 giorni ad ASTI; Più 45,13 in contanti, pagati il 25/2/2011",
  #   "total": 1456.0,
  #   "vat": "20.00%",
  #   "bank_transfer": 1456.0,
  #   "due_date": new Date("2011-03-07T01:00:00+0100"),
  #   "paid_date": new Date("2011-03-07T01:00:00+0100")
  # }

  # $newInvoice{'invoice_date'} = $params->{'invoice_date'};
  # ...

  if ($log_level>1) { $self->api_log->debug("BookKeeping::Controller::API::putReceivableInvoice | new Invoice: ".Dumper($params)); }

  $self->respond_to(
    json => { json => { status => $status} },
    txt  => { text => $status }
  );
}

sub getReceivableInvoicePDF {
  my $self  = shift;
  my $log_level = 2;
  my $invoice_id  = $self->param('invoice_id');
  my $status='OK';
  my %hash;

  my $rua=$self->req->headers->user_agent;
  my $ip=$self->tx->remote_address;
  if ($log_level>0) {
    $self->api_log->debug("BookKeeping::Controller::API::putReceivableInvoice | Request by $rua @ $ip");
  }

  # get PDF from backend ...

  $self->respond_to(
    pdf => sub {
      # $self->tx->res->headers->header('content-disposition' => "attachment; filename=$invoice_id.pdf;");
      $self->render(text => 'In corso di implementazione');
    },
    txt => sub { $self->render(text => 'In corso di implementazione'); },
  );

  $self->respond_to(
    json => { json => \%hash },
    csv  => { text => 'TBD' },
  );
}

"The oracle has spoken (quietly)";
