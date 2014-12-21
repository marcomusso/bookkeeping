package BookKeeping::Controller::Auth;

use base 'Mojolicious::Controller';
use strict;
use warnings;
use Data::Dumper;
use Mojo::Log;

# Customize log file location and minimum log level
my $log = Mojo::Log->new(path => 'log/auth.log', level => 'debug');
my $debug=1; # livello del log

sub create {
    my $self     = shift;
    my $db       = $self->db;
    my $email    = $self->param('email');
    my $password = $self->param('password');

    # my $mysql_sql="SELECT * from users WHERE email=\"$email\" AND password=\"".crypt($password,$password)."\"";
    # my $mysql_sth=$mysql_dbh->prepare($mysql_sql);
    # $mysql_sth->execute or $log->debug("#email SQL Error: $DBI::errstr\n");
    # my $user = $mysql_sth->fetchall_arrayref({});
    # $mysql_sth->finish();

    if ($debug>0) { $log->debug("BookKeeping::Controller::Auth::create"); }

    if ( $email  && $user->[0]->{id} ) {
        if ($debug>0) { $log->debug("BookKeeping::Controller::Auth::create email ok for $user->[0]->{email}"); }
        $self->session(
            user_id    => $user->[0]->{id},
            email      => $user->[0]->{email},
        )->redirect_to('/');
    } else {
        if ($debug>0) { $log->debug("BookKeeping::Controller::Auth::create email failed for $email"); }
        $self->flash( error => 'Unknown email or wrong password' )->redirect_to('auths_create_form');
    }
}

sub delete {
    my $self     = shift;

    if ($debug>0) { $log->debug("BookKeeping::Controller::Auth::delete logout for ".$self->session('email')); }

    $self->session( user_id => '', email => '' )->redirect_to('auths_create_form');
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
