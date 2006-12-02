package Handel::Schema::RDBO::DB;
use strict;
use warnings;

BEGIN {
    use base qw/Rose::DB/;
};

__PACKAGE__->register_db(
    domain   => 'handel',
    type     => 'bogus',
    driver   => 'sqlite'
);

1;
__END__
