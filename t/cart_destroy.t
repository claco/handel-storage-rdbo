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
        plan tests => 34;
    };

    use_ok('Handel::Test::RDBO::Cart');
    use_ok('Handel::Test::RDBO::Cart::Item');
    use_ok('Handel::Constants', qw(:cart));
    use_ok('Handel::Exception', ':try');
};


## This is a hack, but it works. :-)
my $schema = Handel::Test->init_schema(no_populate => 1);
my $altschema = Handel::Test->init_schema(db_file => 'althandel.db', namespace => 'Handel::AltSchema');

&run('Handel::Test::RDBO::Cart', 'Handel::Test::RDBO::Cart::Item', 1);

sub run {
    my ($subclass, $itemclass, $dbsuffix) = @_;

    Handel::Test->populate_schema($schema, clear => 1);
    local $ENV{'HandelDBIDSN'} = $schema->dsn;


    ## Test for Handel::Exception::Argument where first param is not a hashref
    {
        try {
            local $ENV{'LANG'} = 'en';
            $subclass->destroy(id => '1234');

            fail('no exception thrown');
        } catch Handel::Exception::Argument with {
            pass('caught argument exception');
            like(shift, qr/not a hash/i, 'not a hash in message');
        } otherwise {
            fail('caught other exception');
        };
    };


    my $total_carts = $schema->resultset('Carts')->count;
    ok($total_carts, 'table has carts');

    my $total_items = $schema->resultset('CartItems')->count;
    ok($total_items, 'table has items');


    ## Destroy a single cart via instance
    {
        my $it = $subclass->search({
            id => '22222222-2222-2222-2222-222222222222'
        });
        isa_ok($it, 'Handel::Iterator');
        is($it, 1, 'loaded 1 cart');

        my $cart = $it->first;
        isa_ok($cart, 'Handel::Test::RDBO::Cart');
        isa_ok($cart, $subclass);

        my $related_items = $cart->count;
        is($related_items, 1, 'has 1 item');
        is($cart->subtotal+0, 9.99, 'subtotal is 9.99');

        $cart->destroy;

        my $reit = $subclass->search({
            id => '22222222-2222-2222-2222-222222222222'
        });
        isa_ok($reit, 'Handel::Iterator');
        is($reit, 0, 'has no cart');

        my $recart = $reit->first;
        is($recart, undef, 'has no cart');

        my $remaining_carts = $schema->resultset('Carts')->count;
        my $remaining_items = $schema->resultset('CartItems')->count;

        is($remaining_carts, $total_carts - 1, 'unrelated carts in table');
        is($remaining_items, $total_items - $related_items, 'unrelated items in table');

        $total_carts--;
        $total_items -= $related_items;
    };


    ## Destroy multiple carts with wildcard filter
    {
        my $carts = $subclass->search({description => {like => 'Saved%'}});
        isa_ok($carts, 'Handel::Iterator');
        is($carts, 1, 'loaded 1 cart');

        my $related_items = $carts->first->items->count;
        ok($related_items, 'has items');

        $subclass->destroy({
            description => {like => 'Saved%'}
        });

        $carts = $subclass->search({description => {like => 'Saved%'}});
        isa_ok($carts, 'Handel::Iterator');
        is($carts, 0, 'cart not loaded');

        my $remaining_carts = $schema->resultset('Carts')->count;
        my $remaining_items = $schema->resultset('CartItems')->count;

        is($remaining_carts, $total_carts - 1, 'table has unrelated carts');
        is($remaining_items, $total_items - $related_items, 'table has unrelated items');
    };


    ## Destroy carts on an instance
    {
        my $instance = bless {}, $subclass;
        my $carts = $subclass->search;
        isa_ok($carts, 'Handel::Iterator');
        is($carts, 1, 'loaded 1 cart');

        $instance->destroy({
            description => {like => '%'}
        });

        $carts = $subclass->search;
        isa_ok($carts, 'Handel::Iterator');
        is($carts, 0, 'no carts loaded');
    };
};



## pass in storage instead
{
    my $storage = Handel::Test::RDBO::Cart->storage_class->new;
    local $ENV{'HandelDBIDSN'} = $altschema->dsn;

    is($altschema->resultset('Carts')->search({id => '11111111-1111-1111-1111-111111111111'})->count, 1, 'cart found in alt storage');
    Handel::Test::RDBO::Cart->destroy({
        id => '11111111-1111-1111-1111-111111111111'
    }, {
        storage => $storage
    });
    is($altschema->resultset('Carts')->search({id => '11111111-1111-1111-1111-111111111111'})->count, 0, 'cart removed from alt storage');
};


## don't unset self if no result is returned
{
    my $storage = Handel::Test::RDBO::Cart->storage_class->new;
    local $ENV{'HandelDBIDSN'} = $altschema->dsn;

    my $cart = Handel::Test::RDBO::Cart->search({id => '22222222-2222-2222-2222-222222222222'}, {storage => $storage})->first;
    ok($cart, 'cart still defined if nothing deleted');

    no warnings 'redefine';
    local *Handel::Storage::RDBO::Result::delete = sub {};
    $cart->destroy;
    ok($cart, 'cart still defined if delete returns nothing');
};
