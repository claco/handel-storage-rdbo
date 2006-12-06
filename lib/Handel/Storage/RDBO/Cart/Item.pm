package Handel::Storage::RDBO::Cart::Item;
use warnings;
use strict;

BEGIN {
    use base qw/Handel::Storage::RDBO/;
    use Handel::Constraints qw/:all/;
};

__PACKAGE__->setup({
    schema_class     => 'Handel::Schema::RDBO::Cart::Item',
    currency_columns => [qw/price/],
    constraints      => {
        quantity     => {'Check Quantity' => \&constraint_quantity},
        price        => {'Check Price'    => \&constraint_price},
        id           => {'Check Id'       => \&constraint_uuid},
        cart         => {'Check Cart'     => \&constraint_uuid}
    },
    default_values   => {
        id           => sub {__PACKAGE__->new_uuid(shift)},
        price        => 0,
        quantity     => 1
    }
});

1;
__END__
