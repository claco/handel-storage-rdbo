# $Id$
package Handel::Schema::RDBO::Cart::Item;
use strict;
use warnings;

BEGIN {
    use base qw/Rose::DB::Object/;
    use Handel::Schema::RDBO::DB;
};

__PACKAGE__->meta->setup(
    table   => 'cart_items',
    columns => [
        id          => {type => 'varchar', primary_key => 1, length => 36, not_null => 1},
        cart        => {type => 'varchar', length => 36, not_null => 1},
        sku         => {type => 'varchar', length => 25, not_null => 1},
        quantity    => {type => 'integer', default => 0, not_null => 1},
        price       => {type => 'decimal', precision => 9, scale => 2, default => 0, not_null => 1},
        description => {type => 'varchar', length => 255, default => undef, not_null => 0}
    ]
);

sub init_db {
    Handel::Schema::RDBO::DB->new(domain => 'handel', type => 'bogus');
};

1;
__END__
