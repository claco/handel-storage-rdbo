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
        plan tests => 38;
    };

    use_ok('Handel::Test::RDBO::Order');
    use_ok('Handel::Test::RDBO::Order::Item');
    use_ok('Handel::Constants', ':order');
    use_ok('Handel::Exception', ':try');
};


## This is a hack, but it works. :-)
my $schema = Handel::Test->init_schema(no_populate => 1);

&run('Handel::Test::RDBO::Order', 'Handel::Test::RDBO::Order::Item', 1);

sub run {
    my ($subclass, $itemclass, $dbsuffix) = @_;

    Handel::Test->populate_schema($schema, clear => 1);
    local $ENV{'HandelDBIDSN'} = $schema->dsn;


    ## test for Handel::Exception::Argument where first param is not a hashref
    {
        try {
            $subclass->delete(id => '1234');

            fail;
        } catch Handel::Exception::Argument with {
            pass;
        } otherwise {
            fail;
        };
    };


    my $total_items = $schema->resultset('OrderItems')->count;
    ok($total_items);


    ## Delete a single order item contents and validate counts
    {
        my $it = $subclass->search({
            id => '22222222-2222-2222-2222-222222222222'
        });
        isa_ok($it, 'Handel::Iterator');
        is($it, 1);

        my $order = $it->first;
        isa_ok($order, 'Handel::Order');
        isa_ok($order, $subclass);

        my $related_items = $order->count;
        is($related_items, 1);
        cmp_currency($order->subtotal+0, 5.55);
        if ($subclass ne 'Handel::Order') {
            #is($order->custom, 'custom');
        };

        is($order->delete({sku => 'SKU3333'}), 1);
        is($order->count, 0);
        cmp_currency($order->subtotal+0, 5.55);

        my $reit = $subclass->search({
            id => '22222222-2222-2222-2222-222222222222'
        });
        isa_ok($reit, 'Handel::Iterator');
        is($reit, 1);

        my $reorder = $reit->first;
        isa_ok($reorder, 'Handel::Order');
        isa_ok($reorder, $subclass);
        is($reorder->count, 0);
        cmp_currency($reorder->subtotal+0, 5.55);
        if ($subclass ne 'Handel::Order') {
            #is($reorder->custom, 'custom');
        };

        my $remaining_items = $schema->resultset('OrderItems')->count;
        is($remaining_items, $total_items - $related_items);

        $total_items -= $related_items;
    };


    ## Delete multiple order item contents with wildcard filter and validate counts
    {
        my $it = $subclass->search({
            id => '11111111-1111-1111-1111-111111111111'
        });
        isa_ok($it, 'Handel::Iterator');
        is($it, 1);

        my $order = $it->first;
        isa_ok($order, 'Handel::Order');
        isa_ok($order, $subclass);

        my $related_items = $order->count;
        is($related_items, 2);
        cmp_currency($order->subtotal+0, 5.55);
        if ($subclass ne 'Handel::Order') {
            #is($order->custom, 'custom');
        };

        ok($order->delete({sku => 'SKU%'}));
        is($order->count, 0);
        cmp_currency($order->subtotal+0, 5.55);

        my $reit = $subclass->search({
            id => '11111111-1111-1111-1111-111111111111'
        });
        isa_ok($reit, 'Handel::Iterator');
        is($reit, 1);

        my $reorder = $reit->first;
        isa_ok($reorder, 'Handel::Order');
        isa_ok($reorder, $subclass);
        is($reorder->count, 0);
        cmp_currency($reorder->subtotal+0, 5.55);
        if ($subclass ne 'Handel::Order') {
            #is($reorder->custom, 'custom');
        };

        my $remaining_items = $schema->resultset('OrderItems')->count;
        is($remaining_items, $total_items - $related_items);
    };

};
