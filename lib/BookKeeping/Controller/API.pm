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

TBW

Formato della richiesta:

  /api/

Esempio:

  # curl http://<URL>/api/v2/

Oppure, in JSON:


=cut
sub getSession {
  my $self = shift;
  my $debug=1;

  # Customize log file location and minimum log level
  my $log   = Mojo::Log->new(path => 'log/api.log', level => 'debug');

  my ($sec,$min,$hour,$day,$month,$year) = (localtime(time-60*60*24))[0,1,2,3,4,5];
  my $startlocale="$day/".($month+1)."/".($year+1900)." ".sprintf("%2d",$hour).":".sprintf("%2d",$min);
  ($sec,$min,$hour,$day,$month,$year) = (localtime(time))[0,1,2,3,4,5];
  my $endlocale="$day/".($month+1)."/".($year+1900)." ".sprintf("%2d",$hour).":".sprintf("%2d",$min);

  my %defaults=('theme'       => 'default',
                'email'       => '',
                'startepoch'  => time-60*60*24*365, # now - 1year
                'endepoch'    => time,             # now
                'timerange'   => 2,
                'startlocale' => $startlocale,
                'endlocale'   => $endlocale,
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

TBW

Formato della richiesta:

  /api/

Esempio:

  # curl http://<URL>/api/v2/

Oppure, in JSON:


=cut
sub setSession {
  my $self  = shift;
  my $debug = 1;

  # Customize log file location and minimum log level
  my $log   = Mojo::Log->new(path => 'log/api.log', level => 'debug');

  my $rua=$self->req->headers->user_agent;
  my $ip=$self->tx->remote_address;
  if ($debug>0) {
    $log->debug("BookKeeping::Controller::API::setSession | Request by $rua @ $ip");
  }

  my $params = $self->req->json;

  # store known parameters in session!
  $self->session->{env_display}= $params->{'env_display'};
  $self->session->{env_code}   = $params->{'env_code'};
  $self->session->{startepoch} = $params->{'startepoch'};
  $self->session->{endepoch}   = $params->{'endepoch'};
  $self->session->{timerange}  = $params->{'timerange'};
  $self->session->{username}   = $params->{'username'};;
  $self->session->{theme}      = $params->{'theme'};
  $self->session->{units}      = $params->{'units'};

  my ($sec,$min,$hour,$day,$month,$year) = (localtime($params->{'startepoch'}))[0,1,2,3,4,5];
  my $startlocale="$day/".($month+1)."/".($year+1900)." ".sprintf("%d",$hour).":".sprintf("%02d",$min);
  ($sec,$min,$hour,$day,$month,$year) = (localtime($params->{'endepoch'}))[0,1,2,3,4,5];
  my $endlocale="$day/".($month+1)."/".($year+1900)." ".sprintf("%d",$hour).":".sprintf("%02d",$min);

  $self->session->{startlocale} = $startlocale;
  $self->session->{endlocale}   = $endlocale;
  $self->session->{news_date}   = $params->{'news_date'};

  if ($debug>1) { $log->debug("BookKeeping::Controller::API::setSession | Session: ". Dumper($self->session)); }

  $self->respond_to(
    json => { json => { status => 'OK'} },
    txt  => { text => 'OK' }
  );
}

=head2 getNews

TBW

Formato della richiesta:

  /api/

Esempio:

  # curl http://<URL>/api/v2/

Oppure, in JSON:


=cut
sub getNews {
  my $self      = shift;
  my $dbh       = $self->db;

  my $mysql_sql='';
  my $text_data='';
  my %hash;
  my %dthash;

  # Customize log file location and minimum log level
  my $log   = Mojo::Log->new(path => 'log/api.log', level => 'debug');

  my $rua=$self->req->headers->user_agent;
  my $ip=$self->tx->remote_address;
  if ($debug>0) {
    $log->debug("BookKeeping::Controller::API::getNews | Request by $rua @ $ip");
  }

  $mysql_sql="SELECT date,message FROM news order by date desc";
  my $mysql_sth=$dbh->prepare($mysql_sql);
  $mysql_sth->execute or warn "#SQL Error: $DBI::errstr\n";
  if ($debug>0) { $log->debug("BookKeeping::Controller::API::getNews | performing: $mysql_sql"); }
  my $data = $mysql_sth->fetchall_arrayref();
  if ($debug>1) { $log->debug("BookKeeping::Controller::API::getNews | Resultset was: ".Dumper($data)); }
  $mysql_sth->finish();

  # csv OK, json OK
  $text_data="date,message\n";

  my $totalRecords=0;
  if (@$data == 0) {
    push @{$hash{'aaData'}}, ['Nessuna novit&agrave;',''];
  } else {
    foreach my $row (@$data) {
      $text_data.="@$row[0],@$row[1]\n";
      push @{$hash{'news'}}, $row;
      push @{$hash{'aaData'}}, $row;
      $totalRecords+=1;
    }
  }
  push @{$hash{'iTotalRecords'}}, $totalRecords;
  push @{$hash{'iTotalDisplayRecords'}}, $totalRecords;

  $self->respond_to(
    json => { json => \%hash },
    dt   => { json => \%dthash },
    csv  => { text => $text_data }
  );
}

"The oracle has spoken (quietly)";
