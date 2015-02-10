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

  my $dt = DateTime->from_epoch( epoch => time );
  my $year = $dt->year; # current year
  $dt = DateTime->new( # yyyy-01-01 01:00:00.000
    year   => $year,
    month  => 1,
    day    => 1,
    hour   => 1,
    minute => 0,
    second => 0,
    nanosecond => 0
  );

  my %defaults=('theme'       => 'default',
                'email'       => '',
                'startepoch'  => $dt->epoch, # start of the current year
                'endepoch'    => time,       # now
                'timerange'   => 0
               );

  my $rua=$self->req->headers->user_agent;
  my $ip=$self->tx->remote_address;
  if ($log_level>0) {
    my $user='';
    if ($self->session->{email} and $self->session->{email} ne '') {
      $user=' (logged user: '.$self->session->{email}.')';
    }
    $self->api_log->debug("BookKeeping::Controller::API::getSession | Request by $rua @ $ip".$user);
  }

  # without values let's use the default ones in %defaults
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
  my $log_level=$self->log_level;

  my $rua=$self->req->headers->user_agent;
  my $ip=$self->tx->remote_address;
  if ($log_level>0) {
    my $user='';
    if ($self->session->{email} and $self->session->{email} ne '') {
      $user=' (logged user: '.$self->session->{email}.')';
    }
    $self->api_log->debug("BookKeeping::Controller::API::setSession | Request by $rua @ $ip".$user);
  }

  my $params = $self->req->json;

  # store known parameters in session!
  $self->session->{startepoch} = $params->{'startepoch'};
  $self->session->{endepoch}   = $params->{'endepoch'};
  $self->session->{timerange}  = $params->{'timerange'};
  $self->session->{theme}      = $params->{'theme'};

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
  my $log_level=$self->log_level;

  my $startdate = DateTime->from_epoch(
    epoch => $self->session->{'startepoch'}
  );
  my $enddate = DateTime->from_epoch(
    epoch => $self->session->{'endepoch'}
  );

  if ($log_level>1) {
    $self->api_log->debug("BookKeeping::Controller::API::getReceivableInvoices | Resultset ".Dumper($startdate));
  }

  my $text_data="invoice_id,workorder,invoice_date,total,due_date,paid_date\n";
  my $sep=';';
  my @invoicesArray=();
  my %invoice;
  my %dt;

  my $rua=$self->req->headers->user_agent;
  my $ip=$self->tx->remote_address;
  if ($log_level>0) {
    my $user='';
    if ($self->session->{email} and $self->session->{email} ne '') {
      $user=' (logged user: '.$self->session->{email}.')';
    }
    $self->api_log->debug("BookKeeping::Controller::API::getReceivableInvoices | Request by $rua @ $ip".$user);
  }

  my $invoices=$db->get_collection('invoices_receivable');
  my $all_invoices=$invoices->find({'invoice_date' => { '$gte' => $startdate, '$lte' => $enddate } });

  while (my $inv = $all_invoices->next) {
      # JSON array
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

  # TODO handle .dt return format, something like:

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

  if ($log_level>1) {
    $self->api_log->debug("BookKeeping::Controller::API::getReceivableInvoices | Resultset ".Dumper(@invoicesArray));
  }

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
  my $log_level=$self->log_level;

  my $rua=$self->req->headers->user_agent;
  my $ip=$self->tx->remote_address;
  if ($log_level>0) {
    my $user='';
    if ($self->session->{email} and $self->session->{email} ne '') {
      $user=' (logged user: '.$self->session->{email}.')';
    }
    $self->api_log->debug("BookKeeping::Controller::API::getPayableInvoices | Request by $rua @ $ip".$user);
  }

  # TODO get payable and render to the caller

  $self->respond_to(
    json => { json => { dummy => 'yes' } },
    # csv  => { text => $text_data },
    # TODO datatable format
    # dt => { json => \%dt }
  );
}

=head2 putReceivableInvoice

  /api/invoice.json

TBW

=cut
sub putReceivableInvoice {
  my $self  = shift;
  my $db=$self->db;
  my $log=$self->api_log;
  my $log_level=$self->log_level;

  my $status='OK';
  my %newInvoice;

  my $rua=$self->req->headers->user_agent;
  my $ip=$self->tx->remote_address;
  if ($log_level>0) {
    my $user='';
    if ($self->session->{email} and $self->session->{email} ne '') {
      $user=' (logged user: '.$self->session->{email}.')';
    }
    $self->api_log->debug("BookKeeping::Controller::API::putReceivableInvoice | Request by $rua @ $ip".$user);
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

sub getReceivableInvoice {
  my $self = shift;
  my $db=$self->db;
  my $log=$self->api_log;
  my $log_level=$self->log_level;

  my $invoice_id = $self->param('invoice_id');

  my $rua=$self->req->headers->user_agent;
  my $ip=$self->tx->remote_address;
  if ($log_level>0) {
    my $user='';
    if ($self->session->{email} and $self->session->{email} ne '') {
      $user=' (logged user: '.$self->session->{email}.')';
    }
    $self->api_log->debug("BookKeeping::Controller::API::getReceivableInvoice | Request by $rua @ $ip".$user);
  }

  $self->api_log->debug("BookKeeping::Controller::API::getReceivableInvoice | localfile ".$self->config->{'localdata'}.'/'.$invoice_id.'.pdf');

  # TODO in json is requested respond with invoice details, not pdf

  $self->respond_to(
    pdf => sub {
      $self->render_file(
        'filepath' => $self->config->{'localdata'}.'/invoices/receivable/pdf/'.$invoice_id.'.pdf',
        'format'   => 'pdf',                 # will change Content-Type "application/x-download" to "application/pdf"
        'content_disposition' => 'attachment',   # will change Content-Disposition from "attachment" to "inline"
      );
    },
    json => { status => 'TBD'}
  );
}

sub getCompany {
  my $self = shift;
  my $db=$self->db;
  my $log=$self->api_log;
  my $log_level=$self->log_level;

  my $company_id = $self->param('company_id');
  my %company;

  my $rua=$self->req->headers->user_agent;
  my $ip=$self->tx->remote_address;
  if ($log_level>0) {
    my $user='';
    if ($self->session->{email} and $self->session->{email} ne '') {
      $user=' (logged user: '.$self->session->{email}.')';
    }
    $self->api_log->debug("BookKeeping::Controller::API::getCompany | Request by $rua @ $ip".$user);
  }

  # get company by id

  my $company=$db->get_collection('companies');

  $self->respond_to(
    json => { json => %company }
  );
}

"The oracle has spoken (quietly)";
