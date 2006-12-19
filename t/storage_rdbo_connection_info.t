#!perl -wT
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Handel::Test tests => 4;

    use_ok('Handel::Storage::RDBO');
};


{
    my $connection = {
        driver => 'sqlite',
        type => 'bogus',
        domain => 'handel',
        dsn => 'dbi:SQLite:dbname=F:\CPAN\handel.db'
    };

    my $storage = Handel::Storage::RDBO->new({
        schema_class    => 'Handel::Schema::RDBO::Cart',
        connection_info => $connection
    });
    isa_ok($storage, 'Handel::Storage::RDBO');
    is_deeply($storage->connection_info, $connection, 'connection information was set');

    $storage->connection_info(undef);
    is($storage->connection_info, undef, 'connection info was unset');
};
