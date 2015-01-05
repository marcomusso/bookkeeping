package BookKeeping;

use Mojo::Base 'Mojolicious';
use Mojo::Log;
use POSIX qw(strftime);
use MongoDB;
use MongoDB::OID;
use BookKeeping::Model;

# Customize log file location and minimum log level
my $log = Mojo::Log->new(path => 'log/bookkeeping.log', level => 'debug');

# simple DEBUG levels:
# 1: occasional output in actions
# 2: 1+data dump
my $debug=2;

# This method will run once at server start
sub startup {
  my $self = shift;
  my $version;

  $self->moniker('bookkeeping');
  $log->debug('BookKeeping startup') if $debug>0;
  $self->secrets(['efff74625f7sdrfh3wt95gh45g'],['This secret is used _only_ for validation']);
  $self->sessions->default_expiration(3600*6); # 6 ore
  $version = $self->defaults({version => '0.1&alpha;'});

  ##########################################
  # Plugins
    my $config = $self->plugin('Config');
    # many languages! (debug: MOJO_I18N_DEBUG=1 perl script.pl)
    # $self->plugin(charset => {charset => 'utf8'});
    # $self->plugin(
    #   I18N => {namespace => 'BookKeeping::I18N'},
    #   support_url_langs => [qw(it en)],
    #   default => 'en'
    # );
  ##########################################

  #################################################################################
  # Helpers
    $self->helper(
          db => sub {
            # Init Model
            BookKeeping::Model->init( $config->{db} );
          }
    );
  #################################################################################


  # Router
  my $r = $self->routes;

  # Default layout
  $self->defaults(layout => 'default');

  my $sessions = $self->sessions;
  $self        = $self->sessions(Mojolicious::Sessions->new);
  $self->sessions->cookie_name('bookkeeping');

  $r->namespaces(['BookKeeping::Controller']);

  ###################################################################################################
  # UI
    $r->get('/')                      ->to('pages#home')          ->name('home');
    # login
      $r->route('/login')             ->to('auth#login')          ->name('auth_login');
      $r->route('/logout')            ->to('auth#logout')         ->name('auth_logout');

    # admin role
      $r->route('/books')  ->to('pages#books');
      $r->route('/config') ->to('pages#config');

    # user role
      $r->route('/invoices/receivable') ->to('pages#receivable');
      $r->route('/invoices/payable')    ->to('pages#payable');
      $r->route('/feedback')            ->to('pages#feedback');
      $r->route('/credits')             ->to('pages#credits');
      $r->route('/preferences')         ->to('pages#preferences');
  ###################################################################################################

  ###################################################################################################
  # Public API
    $r->route('/api/getreceivableinvoices', format => [qw(csv json)]) ->via('get')  ->to('API#getReceivableInvoices');
    $r->route('/api/invoice',               format => [qw(json)])     ->via('put')  ->to('API#putReceivableInvoice');
    # TODO: get single invoice by id
    # $r->route('/api/invoice/:invoice_id', invoice_id => qr/(\d+)-(\d+)/, format => [qw(json)]) ->via('get')   ->to('API#getReceivableInvoice');
  ###################################################################################################

  ###################################################################################################
  # Private APIs
    $r->route('/api/docs')                             ->to('API#docs');
    $r->route('/api/getSession', format => [qw(json)]) ->to('API#getSession');
    $r->route('/api/setSession')                       ->to('API#setSession');
  ###################################################################################################

  ###################################################################################################
  # auth needed #
    my $auth = $r->under->to('auth#check');
    $auth->route('/configuration')        ->to('pages#configuration');
    $auth->route('/books')                ->to('pages#dashboard');
  ###################################################################################################

  ###################################################################################################
  # Holy cow! Page not found!
  ###################################################################################################
    $r->any('/*whatever' => {whatever => ''} => sub {
      my $c        = shift;
      my $whatever = $c->param('whatever');
      $c->render(template => 'pages/404', status => 404);
    });


}

"Spread your wings";
