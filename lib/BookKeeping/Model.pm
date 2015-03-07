package BookKeeping::Model;

use strict;
use warnings;
use MongoDB;
use MongoDB::OID;
use Mojo::Log;

# Customize log file location and minimum log level
my $log = Mojo::Log->new(path => 'log/model.log', level => 'debug');
my $debug=1;

my $mongoclient;
my $mongodb;

sub init {
  my ($class, $config) = @_;

  $log->debug("No dbname was passed!") unless $config && $config->{dbname};

  unless ( $mongodb ) {
    $mongoclient=MongoDB::MongoClient->new(host => $config->{dbhost});
    $mongodb=$mongoclient->get_database($config->{dbname});
    if ($debug>0) { $log->debug('BookKeeping::Model::init | Created new connection to MongoDB.'); }
  }

  if ($debug>1) { $log->debug('BookKeeping::Model::init | Returned exiting connection to MongoDB.'); }

  return $mongodb;
}

sub db {
  return $mongodb if $mongodb;
  $log->debug("BookKeeping::Model::db | You should init first!");
}

"Your db is served";
