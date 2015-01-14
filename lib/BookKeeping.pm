package BookKeeping;

use Mojo::Base 'Mojolicious';
use Mojo::Log;
use MongoDB;
use MongoDB::OID;
use BookKeeping::Model;

# This method will run once at server start
sub startup {
  my $self = shift;
  my $version;

  $self->moniker('bookkeeping');
  $self->secrets(['efff74625f7sdrfh3wt95gh45g'],['This secret is used _only_ for validation']);
  $self->sessions->default_expiration(3600*6); # 6 ore
  $version = $self->defaults({version => '0.1&alpha;'});

  ##########################################
  # Plugins
    my $config = $self->plugin('Config');
    # many languages! (debug: MOJO_I18N_DEBUG=1 perl script.pl)
    $self->plugin(charset => {charset => 'utf8'});
    $self->plugin(
      I18N => {namespace => 'BookKeeping::I18N'},
      support_url_langs => [qw(it en)],
      default => 'en'
    );
  ##########################################

  #################################################################################
  # Helpers
    $self->helper(
          db => sub {
            # Init Model
            BookKeeping::Model->init( $config->{db} );
          }
    );
    # Log handling
    my $api_log = Mojo::Log->new(path => 'log/api.log', level => 'debug');
    $self->helper(
      api_log => sub { return $api_log }
    );
    $self->helper(
      log_level  => sub { return 2 }
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

    # login
      # $r->route('/login')            ->to('auth#login')       ->name('auth_login');
      # $r->route('/auth')             ->to('auth#create')      ->name('auth_create');
      # $r->route('/logout')           ->to('auth#logout')      ->name('auth_logout');
  ###################################################################################################


    # admin role
      $r->route('/books')  ->to('pages#books');
      $r->route('/config') ->to('pages#config');

    # user role
      $r->route('/invoices/receivable') ->to('pages#receivable');
      $r->route('/invoices/payable')    ->to('pages#payable');
      $r->route('/customers')           ->to('pages#customers');
      $r->route('/feedback')            ->to('pages#feedback');
      $r->route('/credits')             ->to('pages#credits');
      $r->route('/preferences')         ->to('pages#preferences');
  ###################################################################################################

  ###################################################################################################
  # Public API
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
    $auth->route('/api/receivableinvoices',                   format => [qw(csv json)]) ->via('get')  ->to('API#getReceivableInvoices');
    $auth->route('/api/receivableinvoice',                    format => [qw(json)])     ->via('put')  ->to('API#putReceivableInvoice');
    $auth->route('/api/getreceivableinvoicepdf/:invoice_id',  format => [qw(txt pdf)])  ->via('get')  ->to('API#getReceivableInvoicePDF');
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
