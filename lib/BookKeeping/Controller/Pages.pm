package BookKeeping::Controller::Pages;

use Mojo::Base 'Mojolicious::Controller';

sub home {
  my $self = shift;
  $self->render('home');
}

sub preferences {
  my $self = shift;
  $self->render('pages/preferences');
}

sub credits {
  my $self = shift;
  $self->render('pages/credits');
}

sub download {
  my $self = shift;
  $self->render('pages/download');
}

sub receivable {
  my $self = shift;
  $self->render('pages/receivable');
}

sub payable {
  my $self = shift;
  $self->render('pages/payable');
}

sub customers {
  my $self = shift;
  $self->render('pages/customers');
}

sub profile {
  my $self = shift;
  $self->render('pages/profile');
}

sub messages {
  my $self = shift;
  $self->render('pages/messages');
}

"Flip pages";
