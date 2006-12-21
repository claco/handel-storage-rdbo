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
        plan tests => 150;
    };

    use_ok('Handel::Test::RDBO::Order');
    use_ok('Handel::Test::RDBO::Order::Item');

    use_ok('Handel::Order::Item');
    use_ok('Handel::Cart::Item');
    use_ok('Handel::Constants', ':order');
    use_ok('Handel::Exception', ':try');
};


## This is a hack, but it works. :-)
my $schema = Handel::Test->init_schema(no_populate => 1);
$ENV{'HandelDBIDSN'} = $schema->dsn;

&run('Handel::Test::RDBO::Order', 'Handel::Test::RDBO::Order::Item', 1);

sub run {
    my ($subclass, $itemclass, $dbsuffix) = @_;

    Handel::Test->populate_schema($schema, clear => 1);


    ## test for Handel::Exception::Argument where first param is not a hashref
    ## or Handle::Order::Item subclass
    {
        try {
            my $newitem = $subclass->add(id => '1234');

            fail;
        } catch Handel::Exception::Argument with {
            pass;
        } otherwise {
            fail;
        };
    };


    ## test for Handel::Exception::Argument where first param is not a hashref
    ## or Handle::Order::Item subclass
    {
        try {
            my $fakeitem = bless {}, 'FakeItem';
            my $newitem = $subclass->add($fakeitem);

            fail;
        } catch Handel::Exception::Argument with {
            pass;
        } otherwise {
            fail;
        };
    };


    ## add a new item by passing a hashref
    {
        my $it = $subclass->search({
            id => '11111111-1111-1111-1111-111111111111'
        });
        isa_ok($it, 'Handel::Iterator');
        is($it, 1);

        my $order = $it->first;
        isa_ok($order, 'Handel::Order');
        isa_ok($order, $subclass);

        my $data = {
            sku         => 'SKU9999',
            quantity    => 2,
            price       => 1.11,
            total       => 2.22,
            description => 'Line Item SKU 9'
        };
        if ($itemclass ne 'Handel::Order::Item') {
            #$data->{'custom'} = 'custom';
        };

        my $item = $order->add($data);
        isa_ok($item, 'Handel::Order::Item');
        isa_ok($item, $itemclass);
        is($item->orderid, $order->id);
        is($item->sku, 'SKU9999');
        is($item->quantity, 2);
        is($item->price, 1.11);
        is($item->description, 'Line Item SKU 9');
        is($item->total, 2.22);
        if ($itemclass ne 'Handel::Order::Item') {
            #is($item->custom, 'custom');
        };

        is($order->count, 3);
        is($order->subtotal, 5.55);

        my $reit = $subclass->search({
            id => '11111111-1111-1111-1111-111111111111'
        });
        isa_ok($reit, 'Handel::Iterator');
        is($reit, 1);

        my $reorder = $reit->first;
        isa_ok($reorder, 'Handel::Order');
        isa_ok($reorder, $subclass);
        is($reorder->count, 3);

        my $reitemit = $reorder->items({sku => 'SKU9999'});
        isa_ok($reitemit, 'Handel::Iterator');
        is($reitemit, 1);

        my $reitem = $reitemit->first;
        isa_ok($reitem, 'Handel::Order::Item');
        isa_ok($reitem, $itemclass);
        is($reitem->orderid, $reorder->id);
        is($reitem->sku, 'SKU9999');
        is($reitem->quantity, 2);
        is($reitem->price, 1.11);
        is($reitem->description, 'Line Item SKU 9');
        is($reitem->total, 2.22);
        if ($itemclass ne 'Handel::Order::Item') {
            #is($reitem->custom, 'custom');
        };
    };


    ## add a new item by passing a Handel::Order::Item
    {
        my $data = {
            sku         => 'SKU8888',
            quantity    => 1,
            price       => 1.11,
            description => 'Line Item SKU 8',
            total       => 2.22,
            orderid     => '00000000-0000-0000-0000-000000000000'
        };
        if ($itemclass ne 'Handel::Order::Item') {
            #$data->{'custom'} = 'custom';
        };
        my $newitem = $itemclass->create($data);

        isa_ok($newitem, 'Handel::Order::Item');
        isa_ok($newitem, $itemclass);

        my $it = $subclass->search({
            id => '22222222-2222-2222-2222-222222222222'
        });
        isa_ok($it, 'Handel::Iterator');
        is($it, 1);

        my $order = $it->first;
        isa_ok($order, 'Handel::Order');
        isa_ok($order, $subclass);

        my $item = $order->add($newitem);
        isa_ok($item, 'Handel::Order::Item');
        isa_ok($item, $itemclass);
        is($item->orderid, $order->id);
        is($item->sku, 'SKU8888');
        is($item->quantity, 1);
        is($item->price, 1.11);
        is($item->description, 'Line Item SKU 8');
        is($item->total, 2.22);
        if ($itemclass ne 'Handel::Order::Item') {
            #is($item->custom, 'custom');
        };

        is($order->count, 2);
        is($order->subtotal, 5.55);

        my $reit = $subclass->search({
            id => '22222222-2222-2222-2222-222222222222'
        });
        isa_ok($reit, 'Handel::Iterator');
        is($reit, 1);

        my $reorder = $reit->first;
        isa_ok($reorder, 'Handel::Order');
        isa_ok($reorder, $subclass);
        is($reorder->count, 2);

        my $reitemit = $order->items({sku => 'SKU8888'});
        isa_ok($reitemit, 'Handel::Iterator');
        is($reitemit, 1);

        my $reitem = $reitemit->first;
        isa_ok($reitem, 'Handel::Order::Item');
        isa_ok($reitem, $itemclass);
        is($reitem->orderid, $reorder->id);
        is($reitem->sku, 'SKU8888');
        is($reitem->quantity, 1);
        is($reitem->price, 1.11);
        is($reitem->description, 'Line Item SKU 8');
        is($reitem->total, 2.22);
        if ($itemclass ne 'Handel::Order::Item') {
            #is($reitem->custom, 'custom');
        };
    };


    ## add a new item by passing a Handel::Cart::Item
    {
        my $newitem = Handel::Cart::Item->create({
            sku         => 'SKU9999',
            quantity    => 2,
            price       => 1.11,
            description => 'Line Item SKU 9',
            cart        => '00000000-0000-0000-0000-000000000000'
        });
        isa_ok($newitem, 'Handel::Cart::Item');

        my $it = $subclass->search({
            id => '22222222-2222-2222-2222-222222222222'
        });
        isa_ok($it, 'Handel::Iterator');
        is($it, 1);

        my $order = $it->first;
        isa_ok($order, 'Handel::Order');
        isa_ok($order, $subclass);

        my $item = $order->add($newitem);
        isa_ok($item, 'Handel::Order::Item');
        isa_ok($item, $itemclass);
        is($item->orderid, $order->id);
        is($item->sku, 'SKU9999');
        is($item->quantity, 2);
        is($item->price, 1.11);
        is($item->description, 'Line Item SKU 9');
        is($item->total, 2.22);
        if ($itemclass ne 'Handel::Order::Item') {
            #is($item->custom, undef);
        };

        is($order->count, 3);
        is($order->subtotal, 5.55);

        my $reit = $subclass->search({
            id => '22222222-2222-2222-2222-222222222222'
        });
        isa_ok($reit, 'Handel::Iterator');
        is($reit, 1);

        my $reorder = $reit->first;
        isa_ok($reorder, 'Handel::Order');
        isa_ok($reorder, $subclass);
        is($reorder->count, 3);

        my $reitemit = $order->items({sku => 'SKU9999'});
        isa_ok($reitemit, 'Handel::Iterator');
        is($reitemit, 1);

        my $reitem = $reitemit->first;
        isa_ok($reitem, 'Handel::Order::Item');
        isa_ok($reitem, $itemclass);
        is($reitem->orderid, $reorder->id);
        is($reitem->sku, 'SKU9999');
        is($reitem->quantity, 2);
        is($reitem->price, 1.11);
        is($reitem->description, 'Line Item SKU 9');
        is($reitem->total, 2.22);
        if ($itemclass ne 'Handel::Order::Item') {
            #is($reitem->custom, undef);
        };
    };

};


## add a new item by passing a Handel::Order::Item where object has no column
## accessor methods, but the result does
{
    local *Handel::Test::RDBO::Order::Item::can = sub {};

    my $data = {
        sku         => 'SKU8989',
        quantity    => 1,
        price       => 1.11,
        description => 'Line Item SKU 8',
        orderid     => '00000000-0000-0000-0000-000000000001'
    };

    my $newitem = Handel::Test::RDBO::Order::Item->create($data);
    isa_ok($newitem, 'Handel::Test::RDBO::Order::Item');

    my $it = Handel::Test::RDBO::Order->search({
        id => '22222222-2222-2222-2222-222222222222'
    });
    isa_ok($it, 'Handel::Iterator');
    is($it, 1);

    my $order = $it->first;
    isa_ok($order, 'Handel::Test::RDBO::Order');


    my $item = $order->add($newitem);
    isa_ok($item, 'Handel::Test::RDBO::Order::Item');
    is($item->orderid, $order->id);
    is($item->sku, 'SKU8989');
    is($item->quantity, 1);
    is($item->price, 1.11);
    is($item->description, 'Line Item SKU 8');
    is($item->total, 0);

    is($order->count, 4);
    is($order->subtotal, 5.55);

    my $reorderit = Handel::Test::RDBO::Order->search({
        id => '22222222-2222-2222-2222-222222222222'
    });
    isa_ok($reorderit, 'Handel::Iterator');
    is($reorderit, 1);

    my $reorder = $reorderit->first;
    isa_ok($reorder, 'Handel::Test::RDBO::Order');
    is($reorder->count, 4);

    my $reitemit = $order->items({sku => 'SKU8989'});
    isa_ok($reitemit, 'Handel::Iterator');
    is($reitemit, 1);

    my $reitem = $reitemit->first;
    isa_ok($reitem, 'Handel::Test::RDBO::Order::Item');
    is($reitem->orderid, $order->id);
    is($reitem->sku, 'SKU8989');
    is($reitem->quantity, 1);
    is($reitem->price, 1.11);
    is($reitem->description, 'Line Item SKU 8');
    is($reitem->total, 0);
};


## add a new item by passing a Handel::Order::Item where object has no column
## accessor methods and no result accessor methods
{
    no warnings 'once';
    no warnings 'redefine';

    local *Handel::Test::RDBO::Order::Item::can = sub {};
    local *Handel::Storage::RDBO::Result::can = sub {return 1 if $_[1] eq 'sku'};

    my $data = {
        sku         => 'SKU9898',
        quantity    => 1,
        price       => 1.11,
        description => 'Line Item SKU 8',
        orderid     => '00000000-0000-0000-0000-000000000002'
    };

    my $newitem = Handel::Test::RDBO::Order::Item->create($data);
    isa_ok($newitem, 'Handel::Order::Item');

    my $it = Handel::Test::RDBO::Order->search({
        id => '22222222-2222-2222-2222-222222222222'
    });
    isa_ok($it, 'Handel::Iterator');
    is($it, 1);

    my $order = $it->first;
    isa_ok($order, 'Handel::Test::RDBO::Order');


    my $item = $order->add($newitem);
    isa_ok($item, 'Handel::Test::RDBO::Order::Item');
    is($item->orderid, $order->id);
    is($item->sku, 'SKU9898');
    is($item->quantity, 1);
    is($item->price, 0);
    is($item->description, undef);
    is($item->total, 0);

    is($order->count, 5);
    is($order->subtotal, 5.55);

    my $reorderit = Handel::Test::RDBO::Order->search({
        id => '22222222-2222-2222-2222-222222222222'
    });
    isa_ok($reorderit, 'Handel::Iterator');
    is($reorderit, 1);

    my $reorder = $reorderit->first;
    isa_ok($reorder, 'Handel::Test::RDBO::Order');
    is($reorder->count, 5);

    my $reitemit = $order->items();
    isa_ok($reitemit, 'Handel::Iterator');
    is($reitemit, 5);

    my $reitem = $reitemit->last;
    isa_ok($reitem, 'Handel::Test::RDBO::Order::Item');
    is($reitem->orderid, $order->id);
    is($reitem->sku, 'SKU9898');
    is($reitem->quantity, 1);
    is($reitem->price, 0);
    is($reitem->description, undef);
    is($reitem->total, 0);
};
