# $Id$
package Handel::Storage::RDBO::Cart;
use warnings;
use strict;

BEGIN {
    use base qw/Handel::Storage::RDBO/;
    use Handel::Constants qw/CART_TYPE_TEMP/;
    use Handel::Constraints qw/:all/;
};

__PACKAGE__->setup({
    schema_class       => 'Handel::Schema::RDBO::Cart',
    item_storage_class => 'Handel::Storage::RDBO::Cart::Item',
    constraints        => {
        id             => {'Check Id'      => \&constraint_uuid},
        shopper        => {'Check Shopper' => \&constraint_uuid},
        type           => {'Check Type'    => \&constraint_cart_type},
        name           => {'Check Name'    => \&constraint_cart_name}
    },
    default_values     => {
        id             => sub {__PACKAGE__->new_uuid(shift)},
        type           => CART_TYPE_TEMP
    }
});


1;
__END__
