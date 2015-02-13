package BookKeeping;

use Mojo::Base 'Mojolicious';
use Mojo::Log;
use MongoDB;
use MongoDB::OID;
use BookKeeping::Model;

# This method will run once at server start
sub startup {
  my $self = shift;

  $self->moniker('bookkeeping');
  $self->secrets(['CHANGE_ME'],['This secret is used _only_ for validation']);
  $self->sessions->default_expiration(60*60*24); # 24 ore
  my $version = $self->defaults({version => '0.1&alpha;'});
  my $mode = $self->mode;

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
    $self->plugin('RenderFile');
  ##########################################

  #################################################################################
  # Helpers
    $self->helper(
      db => sub {
        # Init Model
        BookKeeping::Model->init( $config->{db} );
      }
    );
    # $self->helper(
    #   config => sub { return $config }
    # );
    # Log handling
    my $api_log = Mojo::Log->new(path => 'log/api.log', level => 'debug');
    $self->helper(
      api_log => sub { return $api_log }
    );
    $self->helper(
      log_level  => sub {
        my $level=1;
        if ($mode ne 'production') { $level = 2; }
        return $level;
      }
    );
    $self->helper(
      ip => sub {
        my $self = shift;
        my $for  = $self->req->headers->header('X-Forwarded-For');
        # if you want to define your own "X-Real-IP" header (or whatever)
        return $for && $for !~ /unknown/i ? $for : undef || $self->req->headers->header('X-Real-IP') || $self->tx->{remote_address};
      }
    );
  #################################################################################

  #################################################################################
  # Hook before_dispatch (needed if behind a reverse proxy, running under hypnotoad)
    if ($mode and $mode eq 'production') {
      $self->hook(before_dispatch => sub {
          my $self = shift;
          push @{$self->req->url->base->path->parts}, splice @{$self->req->url->path->parts}, 0, 1;
      });
    }
  #################################################################################

  # Router
  my $r = $self->routes;

  # Default layout
  $self->defaults(layout => 'default');

  my $sessions = $self->sessions;
  $self = $self->sessions(Mojolicious::Sessions->new);
  $self->sessions->cookie_name('bookkeeping');

  $r->namespaces(['BookKeeping::Controller']);

  ###################################################################################################
  # UI
    $r->route('/')                   ->to('pages#home')           ->name('home');
    $r->route('/profile')            ->to('pages#profile')        ->name('profile');
    $r->route('/messages')           ->to('pages#messages')       ->name('messages');
    # login
      $r->route('/login')             ->to('auth#login')          ->name('auth_login');
      $r->route('/logout')            ->to('auth#logout')         ->name('auth_logout');
  ###################################################################################################

    # admin role
      $r->route('/books')  ->to('pages#books');
      $r->route('/config') ->to('pages#config');

    # user role
      $r->route('/invoices/receivable') ->to('pages#receivable')   ->name('invoicesreceivable');
      $r->route('/invoices/payable')    ->to('pages#payable')      ->name('invoicespayable');
      $r->route('/customers')           ->to('pages#customers')    ->name('customers');
      $r->route('/feedback')            ->to('pages#feedback')     ->name('feedback');
      $r->route('/credits')             ->to('pages#credits')      ->name('credits');
      $r->route('/preferences')         ->to('pages#preferences')  ->name('preferences');
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
    $auth->route('/configuration')        ->to('pages#configuration')  ->name('configuration');
    $auth->route('/books')                ->to('pages#dashboard')      ->name('books');
    $auth->route('/api/receivableinvoice',             format => [qw(json)])     ->via('put')  ->to('API#putReceivableInvoice');
    $auth->route('/api/receivableinvoice/:invoice_id', format => [qw(json pdf)]) ->via('get')  ->to('API#getReceivableInvoice');
    $auth->route('/api/receivableinvoices',            format => [qw(csv json)]) ->via('get')  ->to('API#getReceivableInvoices');
    $auth->route('/api/company/:company_id',           format => [qw(json)])     ->via('get')  ->to('API#getCompany');
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
