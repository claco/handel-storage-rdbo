# $Id$
package Handel::Storage::RDBO::Result;
use warnings;
use strict;

BEGIN {
    use base qw/Handel::Storage::Result/;
};

sub delete {
    return shift->storage_result->delete(cascade => 1, @_);
};

sub discard_changes {
    return shift->storage_result->load(@_);
};

sub update {
    my ($self, $data) = @_;
    my $storage_result = $self->storage_result;

    if ($data) {
        foreach my $key (keys %{$data}) {
            $storage_result->$key($data->{$key});
        };
    };

    $self->storage_result->save;
};

1;
__END__

=head1 NAME

Handel::Storage::RDBO::Result - Result object returned by RDBO storage operations

=head1 SYNOPSIS

    use Handel::Storage::RDBO::Cart;
    
    my $storage = Handel::Storage::RDBO::Cart->new;
    my $result = $storage->create({
        shopper => '11111111-1111-1111-1111-111111111111'
    });
    
    print $result->id;
    print $result->name;

=head1 DESCRIPTION

Handel::Storage::RDBO::Result is a generic wrapper around RDBO objects returned
by various Handel::Storage::RDBO operations. Its main purpose is to abstract
storage result objects away from the Cart/Order/Item classes that use them and
deal with any RDBO specific issues. Each result is assumed to exposed methods
for each 'property' or 'column' it has, as well as support the methods
described below.

=head1 METHODS

=head2 delete

Deletes the current result and all of it's associated items from the current
storage.

    my $storage = Handel::Storage::RDBO::Cart->new;
    my $result = $storage->create({
        shopper => '11111111-1111-1111-1111-111111111111'
    });
    
    $result->add_item({
        sku => 'ABC123'
    });
    
    $result->delete;

=head2 discard_changes

Discards all changes made since the last successful update.

=head2 update

=over

=item Arguments: \%data

=back

Updates the current result with the data specified.

    my $storage = Handel::Storage::RDBO::Cart->new;
    my $result = $storage->create({
        shopper => '11111111-1111-1111-1111-111111111111'
    });
    
    $result->update({
        name => 'My Cart'
    });

=head1 SEE ALSO

L<Handel::Storage::Result>, L<Rose::DB::Object>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
