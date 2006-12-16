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
        plan tests => 119;
    };

    use_ok('Handel::Test::RDBO::Cart');
    use_ok('Handel::Test::RDBO::Cart::Item');
    use_ok('Handel::Constants', ':cart');
    use_ok('Handel::Exception', ':try');
};


## This is a hack, but it works. :-)
my $schema = Handel::Test->init_schema(no_populate => 1);

&run('Handel::Test::RDBO::Cart', 'Handel::Test::RDBO::Cart::Item', 1);

sub run {
    my ($subclass, $itemclass, $dbsuffix) = @_;

    Handel::Test->populate_schema($schema, clear => 1);
    local $ENV{'HandelDBIDSN'} = $schema->dsn;


    ## test for Handel::Exception::Argument where first param is not a hashref
    ## or Handle::Cart::Item subclass
    {
        try {
            local $ENV{'LANG'} = 'en';
            my $newitem = $subclass->add(id => '1234');

            fail('no exception thrown');
        } catch Handel::Exception::Argument with {
            pass('caught argument exception');
            like(shift, qr/not a hash/i, 'not a hash ref in message');
        } otherwise {
            fail('caught other exception');
        };
    };


    ## test for Handel::Exception::Argument where first param is not a hashref
    ## or Handle::Cart::Item subclass
    {
        try {
            local $ENV{'LANG'} = 'en';
            my $fakeitem = bless {}, 'FakeItem';
            my $newitem = $subclass->add($fakeitem);

            fail('no exception thrown');
        } catch Handel::Exception::Argument with {
            pass('caught argument exception');
            like(shift, qr/not a hash.*Handel::Cart::Item/i, 'not a cart in message');
        } otherwise {
            fail('caught other exception');
        };
    };


    ## add a new item by passing a hashref
    {
        my $it = $subclass->search({
            id => '11111111-1111-1111-1111-111111111111'
        });
        isa_ok($it, 'Handel::Iterator');
        is($it, 1, 'returned 1 item');

        my $cart = $it->first;
        isa_ok($cart, 'Handel::Cart');
        isa_ok($cart, $subclass);

        my $data = {
            sku         => 'SKU9999',
            quantity    => 2,
            price       => 1.11,
            description => 'Line Item SKU 9'
        };
        if ($itemclass ne 'Handel::Cart::Item') {
            #$data->{'custom'} = 'custom';
        };

        my $item = $cart->add($data);
        isa_ok($item, 'Handel::Cart::Item');
        isa_ok($item, $itemclass);
        is($item->cart, $cart->id, 'cart is set');
        is($item->sku, 'SKU9999', 'got sku');
        is($item->quantity, 2, 'quantity is 2');
        is($item->price, 1.11, 'price is 1.11');
        is($item->description, 'Line Item SKU 9', 'got description');
        is($item->total, 2.22, 'total is 2.22');
        if ($itemclass ne 'Handel::Cart::Item') {
            #is($item->custom, 'custom', 'got custom');
        };

        is($cart->count, 3, 'count is 3');
        is($cart->subtotal, 7.77, 'subtotal is 7.77');

        my $reit = $subclass->search({
            id => '11111111-1111-1111-1111-111111111111'
        });
        isa_ok($reit, 'Handel::Iterator');
        is($reit, 1, 'got 1 cart');

        my $recart = $reit->first;
        isa_ok($recart, $subclass);
        is($recart->count, 3, 'has 3 items');

        my $reitemit = $cart->items({sku => 'SKU9999'});
        isa_ok($reitemit, 'Handel::Iterator');
        is($reitemit, 1, 'got 1 item');

        my $reitem = $reitemit->first;
        isa_ok($reitem, 'Handel::Cart::Item');
        isa_ok($reitem, $itemclass);
        is($reitem->cart, $cart->id, 'cart is set');
        is($reitem->sku, 'SKU9999', 'got sku');
        is($reitem->quantity, 2, 'quantity is 2');
        is($reitem->price, 1.11, 'price is 1.11');
        is($reitem->description, 'Line Item SKU 9', 'got description');
        is($reitem->total, 2.22, 'total is 2.22');
        if ($itemclass ne 'Handel::Cart::Item') {
            #is($item->custom, 'custom', 'got custom');
        };
    };


    ## add a new item by passing a Handel::Cart::Item
    {
        my $data = {
            sku         => 'SKU8888',
            quantity    => 1,
            price       => 1.11,
            description => 'Line Item SKU 8',
            cart        => '00000000-0000-0000-0000-000000000000'
        };
        if ($itemclass ne 'Handel::Cart::Item') {
            #$data->{'custom'} = 'custom';
        };

        my $newitem = $itemclass->create($data);
        isa_ok($newitem, 'Handel::Cart::Item');
        isa_ok($newitem, $itemclass);

        my $it = $subclass->search({
            id => '22222222-2222-2222-2222-222222222222'
        });
        isa_ok($it, 'Handel::Iterator');
        is($it, 1, 'got 1 cart');

        my $cart = $it->first;
        isa_ok($cart, 'Handel::Cart');
        isa_ok($cart, $subclass);

        my $item = $cart->add($newitem);
        isa_ok($item, 'Handel::Cart::Item');
        isa_ok($item, $itemclass);
        is($item->cart, $cart->id, 'cart is set');
        is($item->sku, 'SKU8888', 'got sku');
        is($item->quantity, 1, 'quantity is 1');
        is($item->price, 1.11, 'price is 1.11');
        is($item->description, 'Line Item SKU 8', 'got description');
        is($item->total, 1.11, 'total is 1.11');
        if ($itemclass ne 'Handel::Cart::Item') {
            #is($item->custom, 'custom', 'got custom');
        };

        is($cart->count, 2, 'has 2 items');
        is($cart->subtotal, 11.10, 'subtotal is 11.10');

        my $recartit = $subclass->search({
            id => '22222222-2222-2222-2222-222222222222'
        });
        isa_ok($recartit, 'Handel::Iterator');
        is($recartit, 1, 'got 1 cart');

        my $recart = $recartit->first;
        isa_ok($recart, $subclass);
        isa_ok($recart, 'Handel::Cart');
        is($recart->count, 2, 'has 2 items');

        my $reitemit = $cart->items({sku => 'SKU8888'});
        isa_ok($reitemit, 'Handel::Iterator');
        is($reitemit, 1, 'have 1 cart');

        my $reitem = $reitemit->first;
        isa_ok($reitem, 'Handel::Cart::Item');
        isa_ok($reitem, $itemclass);
        is($reitem->cart, $cart->id, 'cart is set');
        is($reitem->sku, 'SKU8888', 'sku is set');
        is($reitem->quantity, 1, 'quantity is 1');
        is($reitem->price, 1.11, 'price is 1.11');
        is($reitem->description, 'Line Item SKU 8', 'got description');
        is($reitem->total, 1.11, 'total is 1.11');
        if ($itemclass ne 'Handel::Cart::Item') {
            #is($item->custom, 'custom', 'got custom');
        };
    };
};


## add a new item by passing a Handel::Cart::Item where object has no column
## accessor methods, but the result does
{
    local *Handel::Test::RDBO::Cart::Item::can = sub {};

    my $data = {
        sku         => 'SKU8888',
        quantity    => 1,
        price       => 1.11,
        description => 'Line Item SKU 8',
        cart        => '00000000-0000-0000-0000-000000000001'
    };

    my $newitem = Handel::Test::RDBO::Cart::Item->create($data);
    isa_ok($newitem, 'Handel::Test::RDBO::Cart::Item');

    my $it = Handel::Test::RDBO::Cart->search({
        id => '22222222-2222-2222-2222-222222222222'
    });
    isa_ok($it, 'Handel::Iterator');
    is($it, 1, 'got 1 cart');

    my $cart = $it->first;
    isa_ok($cart, 'Handel::Test::RDBO::Cart');


    my $item = $cart->add($newitem);
    isa_ok($item, 'Handel::Test::RDBO::Cart::Item');
    is($item->cart, $cart->id, 'cart is set');
    is($item->sku, 'SKU8888', 'got sku');
    is($item->quantity, 1, 'quantity is 1');
    is($item->price, 1.11, 'price is 1.11');
    is($item->description, 'Line Item SKU 8', 'got description');
    is($item->total, 1.11, 'total is 1.11');

    is($cart->count, 3, 'has 3 items');
    is($cart->subtotal, 12.21, 'subtotal is 12.21');

    my $recartit = Handel::Test::RDBO::Cart->search({
        id => '22222222-2222-2222-2222-222222222222'
    });
    isa_ok($recartit, 'Handel::Iterator');
    is($recartit, 1, 'got 1 cart');

    my $recart = $recartit->first;
    isa_ok($recart, 'Handel::Test::RDBO::Cart');
    is($recart->count, 3, 'has 3 items');

    my $reitemit = $cart->items({sku => 'SKU8888'});
    isa_ok($reitemit, 'Handel::Iterator');
    is($reitemit, 2, 'has 2 items');

    my $reitem = $reitemit->first;
    isa_ok($reitem, 'Handel::Test::RDBO::Cart::Item');
    is($reitem->cart, $cart->id, 'cart is set');
    is($reitem->sku, 'SKU8888', 'got sku');
    is($reitem->quantity, 1, 'quantity is 1');
    is($reitem->price, 1.11, 'price is 1.11');
    is($reitem->description, 'Line Item SKU 8', 'got description');
    is($reitem->total, 1.11, 'total is 1.11');
};


## add a new item by passing a Handel::Cart::Item where object has no column
## accessor methods and no result accessor methods
{
    no warnings 'once';
    no warnings 'redefine';

    local *Handel::Test::RDBO::Cart::Item::can = sub {};
    local *Handel::Storage::RDBO::Result::can = sub {return 1 if $_[1] eq 'sku'};

    my $data = {
        sku         => 'SKU8888',
        quantity    => 1,
        price       => 1.11,
        description => 'Line Item SKU 8',
        cart        => '00000000-0000-0000-0000-000000000002'
    };

    my $newitem = Handel::Test::RDBO::Cart::Item->create($data);
    isa_ok($newitem, 'Handel::Test::RDBO::Cart::Item');

    my $it = Handel::Test::RDBO::Cart->search({
        id => '22222222-2222-2222-2222-222222222222'
    });
    isa_ok($it, 'Handel::Iterator');
    is($it, 1, 'got 1 cart');

    my $cart = $it->first;
    isa_ok($cart, 'Handel::Test::RDBO::Cart');


    my $item = $cart->add($newitem);
    isa_ok($item, 'Handel::Test::RDBO::Cart::Item');
    is($item->cart, $cart->id, 'cart is set');
    is($item->sku, 'SKU8888', 'got sku');
    is($item->quantity, 1, 'quantity is 1');
    is($item->price, 0, 'price is 0');
    is($item->description, undef, 'no description');
    is($item->total, 0, 'total is 0');

    is($cart->count, 4, 'has 4 items');
    is($cart->subtotal, 12.21, 'subtotal 12.21');

    my $recartit = Handel::Test::RDBO::Cart->search({
        id => '22222222-2222-2222-2222-222222222222'
    });
    isa_ok($recartit, 'Handel::Iterator');
    is($recartit, 1, 'got 1 cart');

    my $recart = $recartit->first;
    isa_ok($recart, 'Handel::Test::RDBO::Cart');
    is($recart->count, 4, 'has 4 items');

    my $reitemit = $cart->items();
    isa_ok($reitemit, 'Handel::Iterator');
    is($reitemit, 4, 'has 4 items');

    my $reitem = $reitemit->last;
    isa_ok($reitem, 'Handel::Test::RDBO::Cart::Item');
    is($reitem->cart, $cart->id, 'cart is set');
    is($reitem->sku, 'SKU8888', 'got sku');
    is($reitem->quantity, 1, 'quantity is 1');
    is($reitem->price, 0, 'price is 0');
    is($reitem->description, undef, 'no description');
    is($reitem->total, 0, 'total is 0');
};