# $Id: Schema.pm 1379 2006-08-22 02:21:53Z claco $
package Handel::Test::Schema;
use strict;
use warnings;

BEGIN {
    use base qw/DBIx::Class::Schema/;
    use Handel::Schema::Cart;
    use Handel::Schema::Cart::Item;
    use Handel::Schema::Order;
    use Handel::Schema::Order::Item;
};

## All 4 classes aren't usually loaded together so we'll do this to avoid both
## sources named 'Items'
__PACKAGE__->register_class('Carts', 'Handel::Schema::Cart');
__PACKAGE__->register_class('CartItems', 'Handel::Schema::Cart::Item');
__PACKAGE__->register_class('Orders', 'Handel::Schema::Order');
__PACKAGE__->register_class('OrderItems', 'Handel::Schema::Order::Item');

sub dsn {
    return shift->storage->connect_info->[0];
};

1;
