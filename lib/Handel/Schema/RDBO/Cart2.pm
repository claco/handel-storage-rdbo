package Handel::Schema::RDBO::Cart2;
use strict;
use warnings;

BEGIN {
    use base qw/Handel::Schema::RDBO::Cart/;
};

__PACKAGE__->meta->table('mycart');
__PACKAGE__->meta->delete_column('name');
__PACKAGE__->meta->add_column(myname => {type => 'varchar', length => 255});

1;
__END__
