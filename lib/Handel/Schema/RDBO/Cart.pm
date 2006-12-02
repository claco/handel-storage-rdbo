package Handel::Schema::RDBO::Cart;
use strict;
use warnings;

BEGIN {
    use base qw/Rose::DB::Object/;
    use Handel::Schema::RDBO::DB;
};

__PACKAGE__->meta->setup(
    db      => Handel::Schema::RDBO::DB->new(domain => 'handel', type => 'bogus'),
    table   => 'cart',
    columns => [
        id          => {type => 'varchar', primary_key => 1, length => 36, not_null => 1},
        shopper     => {type => 'varchar', length => 36, not_null => 1},
        type        => {type => 'boolean', default => 0, not_null => 1},
        name        => {type => 'varchar', length => 50},
        description => {type => 'varchar', length => 255}
    ]
);

1;
__END__
