package Handel::Storage::RDBO;
use warnings;
use strict;

BEGIN {
    use base qw/Handel::Storage/;

    __PACKAGE__->mk_group_accessors('inherited', qw/
        _columns_to_add
        _columns_to_remove
        _schema_instance
        connection_info
        item_relationship
        table_name
    /);
    __PACKAGE__->mk_group_accessors('component_class', qw/
        schema_class
    /);
};

__PACKAGE__->item_relationship('items');
__PACKAGE__->iterator_class('Handel::Iterator::RDBO');
__PACKAGE__->result_class('Handel::Storage::RDBO::Result');

sub add_columns {
    my ($self, @columns) = @_;

    if ($self->_schema_instance) {
        $self->_schema_instance->meta->add_columns(@columns);
    };

    $self->_columns_to_add
        ? push @{$self->_columns_to_add}, @columns
        : $self->_columns_to_add(\@columns);

    return;
};

sub schema_instance {
    my $self = shift;

    # allow unsetting
    if (scalar @_) {
        return $self->_schema_instance(@_);
    };

    if (!$self->_schema_instance) {
        no strict 'refs';

        throw Handel::Exception::Storage(
            -details => translate('SCHEMA_CLASS_NOT_SPECIFIED')
        ) unless $self->schema_class; ## no critic

        my $package = $self->schema_class;
        my $namespace = "$package\:\:".uc($self->new_uuid);
        $namespace =~ s/-//g;

        push @{"$namespace\:\:ISA"}, $package;
        $namespace->import;

        $self->_schema_instance($namespace);
        $self->_configure_schema_instance;
    };

    return $self->_schema_instance;
};

sub setup {
    my ($self, $options) = @_;

    throw Handel::Exception::Argument(
        -details => translate('PARAM1_NOT_HASHREF')
    ) unless ref($options) eq 'HASH'; ## no critic

    # make ->columns/column_accessors w/o happy schema_instance/source
    foreach my $setting (qw/schema_class/) {
        if (exists $options->{$setting}) {
            $self->$setting(delete $options->{$setting});
        };
    }

    $self->SUPER::setup($options);

    return;
};

sub _configure_schema_instance {
    my ($self) = @_;
    my $schema_instance = $self->schema_instance;

    # change the table name
    if ($self->table_name) {
        $schema_instance->meta->table($self->table_name);
    };
};

1;
__END__
