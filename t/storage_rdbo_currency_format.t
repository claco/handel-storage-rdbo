#!perl -wT
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Handel::Test;

    eval 'require DBD::SQLite';
    if($@) {
        plan skip_all => 'DBD::SQLite not installed';
    } else {
        plan tests => 17;
    };

    use_ok('Handel::Storage::RDBO');
    use_ok('Handel::Exception', ':try');
};

my $schema = Handel::Test->init_schema;
$ENV{'HandelDBIDSN'} = $schema->dsn;


my $storage = Handel::Storage::RDBO->new({
    schema_class     => 'Handel::Schema::RDBO::Cart::Item',
    currency_format  => 'FMT_NAME',
    currency_columns => [qw/price/]
});


my $item = $storage->search->first;
isa_ok($item->price, 'Handel::Currency');
is($item->price->_format, 'FMT_NAME', 'format was set');
is($item->price->format, '1.11 US Dollar', 'got long format name');



$storage->currency_format('FMT_HTML');
$item = $storage->search->first;
isa_ok($item->price, 'Handel::Currency');
is($item->price->_format, 'FMT_HTML', 'format was set');
is($item->price->format, '&#x0024;1.11', 'got html format');


$storage->currency_format(undef);
$item = $storage->search->first;
isa_ok($item->price, 'Handel::Currency');
is($item->price->_format, undef, 'format is not set');
is($item->price->format, '1.11 USD', 'got short format');


{
    local $ENV{'HandelCurrencyFormat'} = 'FMT_NAME';
    my $item = $storage->search->first;
    isa_ok($item->price, 'Handel::Currency');
    is($item->price->_format, undef, 'no format is set');
    is($item->price->format, '1.11 US Dollar', 'got long format');
};


{
    my $item = $storage->search->first;
    isa_ok($item->price, 'Handel::Currency');
    is($item->price->_format, undef, 'no format is set');
    is($item->price->format, '1.11 USD', 'for short name format');
};
