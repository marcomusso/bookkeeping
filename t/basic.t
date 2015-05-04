use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

my $api_prefix='/api';

my $t = Test::Mojo->new('BookKeeping');
$t->ua->max_redirects(1);

# APIs
  $t->get_ok("$api_prefix/getSession.json")
    ->status_is(200)
    ->content_like(qr/"theme":"default"/);

  # get single invoice/all invoices, with error because not authenticated
  $t->get_ok("$api_prefix/receivableinvoice/0012-14.json")
    ->status_is(200)
    ->content_like(qr/ACCESS_DENIED/);
  $t->get_ok("$api_prefix/receivableinvoices.json")
    ->status_is(200)
    ->content_like(qr/ACCESS_DENIED/);

# GUI
  $t->get_ok("/")                    ->status_is(200) ->content_isnt('Server error');
  $t->get_ok('/invoices/receivable') ->status_is(200) ->content_isnt('Server error');
  $t->get_ok('/invoices/payable')    ->status_is(200) ->content_isnt('Server error');
  $t->get_ok('/customers')           ->status_is(200) ->content_isnt('Server error');
  $t->get_ok('/feedback')            ->status_is(200) ->content_isnt('Server error');
  $t->get_ok('/credits')             ->status_is(200) ->content_isnt('Server error');
  $t->get_ok('/preferences')         ->status_is(200) ->content_isnt('Server error');

done_testing();

# Nice!
#$t->reset_session;
