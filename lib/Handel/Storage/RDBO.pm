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

    use Handel::Exception qw/:try/;
    use Handel::L10N qw/translate/;
    use Clone ();
    use Scalar::Util qw/blessed weaken/;
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

sub clone {
    my $self = shift;

    throw Handel::Exception::Storage(
        -details => translate('NOT_CLASS_METHOD')
    ) unless blessed($self); ## no critic

    # a hack indeed. clone barfs on some DBI inards, so lets move out the
    # schema instance while we clone and put it back
    if ($self->_schema_instance) {
        my $db = $self->_schema_instance->meta->db;
        $self->_schema_instance->meta->db(undef);

        my $clone = Clone::clone($self);

        $self->_schema_instance->meta->db($db);

        return $clone;
    } else {
        return $self->SUPER::clone;
    };
};

sub column_accessors {
    my $self = shift;
    my $accessors = {};

    if ($self->_schema_instance) {
        my @columns = $self->_schema_instance->columns;
        foreach my $column (@columns) {
            my $accessor = $column->alias;
            if (!$accessor) {
                $accessor = $column->name;
            };
            $accessors->{$column} = $accessor;
        };
    } else {
        my @columns = $self->schema_class->meta->columns;
        foreach my $column (@columns) {
            my $accessor = $column->alias;
            if (!$accessor) {
                $accessor = $column->name;
            };
            $accessors->{$column} = $accessor;
        };

        if ($self->_columns_to_add) {
            my $adding = Clone::clone($self->_columns_to_add);

            while (my $column = shift @{$adding}) {
                my $column_info = ref $adding->[0] ? shift(@{$adding}) : {};
                my $accessor = $column_info->{'alias'};
                if (!$accessor) {
                    $accessor = $column;
                };
                $accessors->{$column} = $accessor;
            };
        };

        if ($self->_columns_to_remove) {
            foreach my $column (@{$self->_columns_to_remove}) {
                delete $accessors->{$column};
            };
        };
    };

    return $accessors;
};

sub columns {
    my $self = shift;

    if ($self->_schema_instance) {
        return $self->_schema_instance->meta->column_names;
    } else {
        return keys %{$self->column_accessors};
    };
};

sub create {
    my ($self, $data) = (shift, shift);
    my $schema = $self->schema_instance;
    my $result_class = $self->result_class;

    throw Handel::Exception::Argument(
        -details => translate('PARAM1_NOT_HASHREF')
    ) unless ref($data) eq 'HASH'; ## no critic

    $self->set_default_values($data);
    $self->check_constraints($data);
    $self->validate_data($data);

    my $storage_result = $schema->new(%{$data});
    $storage_result->save(@_);
    
    return $result_class->create_instance(
        $storage_result, $self
    );
};

sub has_column {
    my ($self, $column) = @_;

    if ($self->_schema_instance) {
        return grep $column, ($self->schema_instance->meta->column_names);
    } else {
        return $self->SUPER::has_column($column);
    };
};

sub primary_columns {
    my ($self, @columns) = @_;

    if ($self->_schema_instance) {
        if (@columns) {
            $self->schema_instance->meta->primary_key_column_names(@columns);
        };

        return $self->schema_instance->meta->primary_key_column_names;
    } else {
        if (@columns) {
            $self->_primary_columns(\@columns);
        };

        return $self->_primary_columns ?
            @{$self->_primary_columns} :
            $self->schema_class->meta->primary_key_column_names;
    };
};

sub remove_columns {
    my ($self, @columns) = @_;

    if ($self->_schema_instance) {
        foreach my $column (@columns) {
            $self->_schema_instance->meta->delete_column($column);
        };
    };

    $self->_columns_to_remove
        ? push @{$self->_columns_to_remove}, @columns
        : $self->_columns_to_remove(\@columns);

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

sub txn_begin {
    my ($self, $result) = @_;

    return $result->db->begin_work;
};

sub txn_commit {
    my ($self, $result) = @_;

    return $result->db->commit;
};

sub txn_rollback {
    my ($self, $result) = @_;

    return $result->db->rollback;
};

sub _configure_schema_instance {
    my ($self) = @_;
    my $schema_instance = $self->schema_instance;
    my $item_storage = $self->item_storage;

    # change the table name
    if ($self->table_name) {
        $schema_instance->meta->table($self->table_name);
    };

    # twiddle columns
    if ($self->_columns_to_add) {
        $schema_instance->meta->add_columns(@{$self->_columns_to_add});
    };
    if ($self->_columns_to_remove) {
        foreach my $column (@{$self->_columns_to_remove}) {
            $schema_instance->meta->delete_column($column);
        };
    };

    if ($item_storage) {
        my $item_relationship = $schema_instance->meta->relationship($self->item_relationship);

        throw Handel::Exception::Storage(-text =>
            translate('SCHEMA_SOURCE_NO_RELATIONSHIP', $self->schema_class, $item_relationship)
        ) unless $item_relationship; ## no critic

        $item_relationship->class($item_storage->schema_instance);

        $item_storage->schema_instance->meta->initialize;
    };

    $schema_instance->meta->initialize;

    # setup db
    if (my $connection_info = $self->connection_info) {
        my $db = Handel::Schema::RDBO::DB->new(domain => 'handel', type => 'bogus')->modify_db(%{$connection_info});
        $schema_instance->meta->db($db);
    };
};

1;
__END__
