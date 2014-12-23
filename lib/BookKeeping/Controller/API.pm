package BookKeeping::Controller::API;

use Mojo::Base 'Mojolicious::Controller';
use DBI;
use Data::Dumper;
use Mojo::Log;
use POSIX qw(strftime locale_h);
use locale;
use Mojo::UserAgent;
use Mojo::IOLoop;

# Customize log file location and minimum log level
my $log = Mojo::Log->new(path => 'log/api.log', level => 'debug');
my $debug=1;

setlocale(LC_CTYPE, "en_US.UTF-8");

# render static docs
sub docs {
  my $self = shift;
  $self->render('api/docs');
}

=head1 BookKeeping PRIVATE API

L'accesso a queste API e' PRIVATO ed avviene tramite il seguente l'URL

  http://<URL>/api/<metodo>/<parametri...>

I parametri delle API vengono passati come URI, per esempio:

  http://<URL>/api/...

I dati verranno restituiti nel formato indicato dall'estensione dell'ultimo parametro (attualmente supportati: csv, json).

Elenco metodi:
=cut

#########################################################################
# Private APIs
#########################################################################

=head2 getSession

Returns the session data to the caller as a JSON obj.

  # curl http://<URL>/api/getsession.json

=cut
sub getSession {
  my $self = shift;
  my $debug=1;

  #  my ($sec,$min,$hour,$day,$month,$year) = (localtime(time-60*60*24))[0,1,2,3,4,5];
  # my $startlocale="$day/".($month+1)."/".($year+1900)." ".sprintf("%2d",$hour).":".sprintf("%2d",$min);
  # ($sec,$min,$hour,$day,$month,$year) = (localtime(time))[0,1,2,3,4,5];
  # my $endlocale="$day/".($month+1)."/".($year+1900)." ".sprintf("%2d",$hour).":".sprintf("%2d",$min);

  my %defaults=('theme'       => 'cosmo',
                'email'       => '',
                'startepoch'  => time-60*60*24*365, # now - 1year
                'endepoch'    => time,             # now
                'timerange'   => 2,
                # 'startlocale' => $startlocale,
                # 'endlocale'   => $endlocale,
               );

  my $rua=$self->req->headers->user_agent;
  my $ip=$self->tx->remote_address;
  if ($debug>0) {
    $log->debug("BookKeeping::Controller::API::getSession | Request by $rua @ $ip");
  }

  # se non ci sono valori validi usare i valori predefiniti di %defaults
    foreach my $key ( keys %defaults ) {
      if (!defined $self->session->{$key} or $self->session->{$key} eq '') {
        $self->session->{$key}=$defaults{$key};
      }
    }

  if ($debug>1) { $log->debug("BookKeeping::Controller::API::getSession | Session: ". Dumper($self->session)); }

  $self->respond_to(
    json => { json => $self->session },
  );
}

=head2 setSession

  /api/setSession.json

TBW

=cut
sub setSession {
  my $self  = shift;
  my $debug = 2;

  my $rua=$self->req->headers->user_agent;
  my $ip=$self->tx->remote_address;
  if ($debug>0) {
    $log->debug("BookKeeping::Controller::API::setSession | Request by $rua @ $ip");
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

  if ($debug>1) { $log->debug("BookKeeping::Controller::API::setSession | Session: ". Dumper($self->session)); }

  $self->respond_to(
    json => { json => { status => 'OK'} },
    txt  => { text => 'OK' }
  );
}

sub getReceivableInvoices {
  my $self  = shift;
  my $debug = 2;
  my $db = $self->db;

  my $text_data="invoice_id,workorder,invoice_date,total,due_date,paid_date\n";
  my $sep=';';
  my %hash;

  my $rua=$self->req->headers->user_agent;
  my $ip=$self->tx->remote_address;
  if ($debug>0) {
    $log->debug("BookKeeping::Controller::API::setSession | Request by $rua @ $ip");
  }

  my $invoices=$db->get_collection('invoices_receivable');
  my $all_invoices=$invoices->find;

  # { "_id" : ObjectId("5493f5c2f0ef319ba6f7a385"), "invoice_date" : "31/12/2011", "invoice_id" : "0020-11", "workorder" : "Finsoft/SPIMI2011", "units" : 19, "cost_per_unit" : 290, "resource" : "Musso", "notes" : "pagata nel 2012", "total" : "5510,00", "vat" : "21,00%", "bank_transfer" : "5.565,10", "due_date" : "10/02/2012", "paid_date" : "10/02/2012" }

  while (my $inv = $all_invoices->next) {
    $hash{$inv->{'invoice_id'}}{'workorder'} = $inv->{'workorder'};
    $hash{$inv->{'invoice_id'}}{'invoice_date'} = $inv->{'invoice_date'};
    $hash{$inv->{'invoice_id'}}{'total'} = $inv->{'total'};
    $hash{$inv->{'invoice_id'}}{'due_date'} = $inv->{'due_date'};
    $hash{$inv->{'invoice_id'}}{'paid_date'} = $inv->{'paid_date'};
    $text_data.=$inv->{'invoice_id'}.$sep.
                $inv->{'workorder'}.$sep.
                $inv->{'invoice_date'}.$sep.
                $inv->{'total'}.$sep.
                $inv->{'due_date'}.$sep.
                $inv->{'paid_date'}.
                "\n";
  }

  $self->respond_to(
    json => { json => \%hash },
    csv  => { text => $text_data }
  );
}

sub getPayableInvoices {

}


"The oracle has spoken (quietly)";
