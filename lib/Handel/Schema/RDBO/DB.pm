# $Id$
package Handel::Schema::RDBO::DB;
use strict;
use warnings;

BEGIN {
    use base qw/Rose::DB/;
};
__PACKAGE__->use_private_registry;
__PACKAGE__->register_db(
    domain     => 'handel',
    type       => 'bogus',
    driver     => 'sqlite',
    autocommit => 1
);

1;
__END__
