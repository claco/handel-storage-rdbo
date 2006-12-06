package Handel::Schema::RDBO::Cart;
use strict;
use warnings;

BEGIN {
    use base qw/Rose::DB::Object/;
    use Handel::Schema::RDBO::DB;
};

__PACKAGE__->meta->setup(
    table   => 'cart',
    columns => [
        id          => {type => 'varchar', primary_key => 1, length => 36, not_null => 1},
        shopper     => {type => 'varchar', length => 36, not_null => 1},
        type        => {type => 'boolean', default => 0, not_null => 1},
        name        => {type => 'varchar', length => 50, not_null => 0},
        description => {type => 'varchar', length => 255, not_null => 0}
    ],
    relationships => [
        items => {
            type       => 'one to many',
            class      => 'Handel::Schema::RDBO::Cart::Item',
            column_map => {id => 'cart'}
        }
    ]
);

sub init_db {
    Handel::Schema::RDBO::DB->new(domain => 'handel', type => 'bogus');
};

1;
__END__
