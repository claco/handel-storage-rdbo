# $Id$
package Handel::Checkout::Plugin::TestPlugin;
use strict;
use warnings;
use base 'Handel::Checkout::Plugin';
use Handel::Constants qw(:checkout);

sub register {
    my ($self, $ctx) = @_;

    $self->{'register_called'}++;
    $ctx->add_handler(CHECKOUT_PHASE_INITIALIZE, \&handler, 3);
};

sub init {
    my ($self, $ctx) = @_;

    $self->{'init_called'}++;
};

sub setup {
    my ($self, $ctx) = @_;

    $self->{'setup_called'}++;
};

sub teardown {
    my ($self, $ctx) = @_;

    $self->{'teardown_called'}++;
};

sub handler {
    my ($self, $ctx) = @_;

    $self->{'handler_called'}++;
};

1;
