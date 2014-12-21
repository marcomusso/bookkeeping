package BookKeeping;

use Mojo::Base 'Mojolicious';
use Mojo::Log;
use POSIX qw(strftime);
use MongoDB;
use MongoDB::OID;

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

  $log->debug('BookKeeping startup') if $debug>0;
  $self->secrets(['efff74625f7sdrfh3wt95gh45g'],['XYZ']);
  $self->sessions->default_expiration(3600*6); # 6 ore
  $version = $self->defaults({version => '0.1&alpha;'});

  ##########################################
  # Plugins
    my $config = $self->plugin('Config');
    $self->plugin('TagHelpers');
  ##########################################

  # Router
  my $r = $self->routes;

  $r->namespaces(['BookKeeping::Controller']);

  ###################################################################################################
  # UI
    $r->get('/')         ->to('pages#home')      ->name('home');
    # login
      $r->route('/login')            ->to('auth#create_form')    ->name('auths_create_form');
      $r->route('/auth')             ->to('auth#create')         ->name('auths_create');
      $r->route('/logout')           ->to('auth#delete')         ->name('auth_delete');

    $r->route('/invoices/receivable')        ->to('pages#receivable');
    $r->route('/invoices/payable')           ->to('pages#payable');
    $r->route('/feedback')           ->to('pages#feedback');                    # feedback
    $r->route('/credits')            ->to('pages#credits');                     # credits
    $r->route('/preferences')        ->to('pages#preferences');                 # preferences
  ###################################################################################################

  ###################################################################################################
  # Public API
  ###################################################################################################

  ###################################################################################################
  # Private APIs
    $r->route('/api/docs') ->to('API#docs');
    $r->route('/api/getSession', format => [qw(json)]) ->to('API#getSession');
    $r->route('/api/setSession')                       ->to('API#setSession');
  ###################################################################################################

  ###################################################################################################
  # auth needed #
    my $auth = $r->under->to('auth#check');
    $auth->route('/configuration')        ->to('pages#configuration');
    $auth->route('/books')                ->to('pages#dashboard');
    # $auth->route('/api/docs')           ->to('API#docs');                   # doc API private
  ###################################################################################################

  ###################################################################################################
  # Se arrivate qui troverete la mucca sacra!
  ###################################################################################################
    $r->any('/*whatever' => {whatever => ''} => sub {
      my $c        = shift;
      my $whatever = $c->param('whatever');
      $c->render(template => 'pages/404', status => 404);
    });


}

"Spread your wings";
