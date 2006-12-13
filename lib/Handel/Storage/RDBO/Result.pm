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
