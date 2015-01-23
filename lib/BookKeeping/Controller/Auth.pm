package BookKeeping::Controller::Auth;

use base 'Mojolicious::Controller';
use strict;
use warnings;
use Data::Dumper;
use DateTime;
use Digest::MD5 qw(md5_hex);

sub login {
  my $self = shift;
  my $db = $self->db;
  my $log = $self->api_log;
  my $log_level = $self->log_level;
  my $email = $self->param('email');
  my $password = $self->param('password');

  if ($log_level>0) { $log->debug("BookKeeping::Controller::Auth::login"); }

  my $users=$self->db->get_collection('users');
  my $user=$users->find({"email" => "$email", "password" => crypt($password,$password)});
  # let's retrieve all users that match the previous find (should be one of course)
  my @logged_user=$user->all;

  if ( @logged_user and (0+@logged_user)==1) {
      if ($log_level>0) { $log->debug("BookKeeping::Controller::Auth::login Auth ok for $email"); }
      # set last login time
      $users->update({"_id" => $logged_user[0]->{'_id'}}, {'$set' => {'last_login' => DateTime->now}});
      # save info in session
      $self->session(
          email      => $email,
          role       => $logged_user[0]->{'role'},
          firstname  => $logged_user[0]->{'firstname'},
          lastname   => $logged_user[0]->{'lastname'},
          gravatar   => 'https://www.gravatar.com/avatar/'.md5_hex($email).'&s=20',
      )->redirect_to('/');
  } else {
      if ($log_level>0) { $log->debug("BookKeeping::Controller::Auth::login Auth failed for $email"); }
      $self->flash( error => 'Unknown email or wrong password' )->redirect_to('/');
  }
}

sub logout {
  my $self = shift;
  my $log = $self->api_log;
  my $log_level = $self->log_level;

  if ($log_level>0) { $log->debug("BookKeeping::Controller::Auth::delete logout for ".$self->session('email')); }

  # clear session
  $self->session( email => '',
                  role => '',
                  firstname => '',
                  lastname => ''
                  )->redirect_to('/');
}

sub check {
  my $self = shift;
  my $log = $self->api_log;
  my $log_level = $self->log_level;

  if ($self->session('email')) {
      return 1;
  } else {
      $self->render(template => 'auth/denied');
      return 0;
  }
}

"The gate will open if...";
