package BookKeeping::Controller::Auth;

use base 'Mojolicious::Controller';
use strict;
use warnings;
use Data::Dumper;
use Mojo::Log;
use DateTime;

# Customize log file location and minimum log level
my $log = Mojo::Log->new(path => 'log/auth.log', level => 'debug');
my $debug=1; # livello del log

sub login {
  my $self     = shift;
  my $db       = $self->db;
  my $email    = $self->param('email');
  my $password = $self->param('password');

  if ($debug>0) { $log->debug("BookKeeping::Controller::Auth::login"); }

  my $users=$self->db->get_collection('users');
  my $user=$users->find({"email" => "$email", "password" => crypt($password,$password)});
  # let's retrieve all users that match the previous find (should be one of course)
  my @logged_user=$user->all;

  if ( @logged_user and (0+@logged_user)==1) {
      if ($debug>0) { $log->debug("BookKeeping::Controller::Auth::login Auth ok for $email"); }
      # set last login time
      $users->update({"_id" => $logged_user[0]->{'_id'}}, {'$set' => {'last_login' => DateTime->now}});
      # save info in session
      $self->session(
          email      => $email,
          role       => $logged_user[0]->{'role'},
          firstname  => $logged_user[0]->{'firstname'},
          lastname   => $logged_user[0]->{'lastname'}
      )->redirect_to('/');
  } else {
      if ($debug>0) { $log->debug("BookKeeping::Controller::Auth::login Auth failed for $email"); }
      $self->flash( error => 'Unknown email or wrong password' )->redirect_to('/');
  }
}

sub logout {
  my $self     = shift;

  if ($debug>0) { $log->debug("BookKeeping::Controller::Auth::delete logout for ".$self->session('email')); }

  # clear session
  $self->session( email => '',
                  role => '',
                  firstname => '',
                  lastname => ''
                  )->redirect_to('/');
}

sub check {
  my $self = shift;

  if ($self->session('email')) {
      return 1;
  } else {
      $self->render(template => 'auth/denied');
      return 0;
  }
}

"The gate will open if...";
