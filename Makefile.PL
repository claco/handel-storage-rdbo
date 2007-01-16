# $Id$
use ExtUtils::MakeMaker;
use strict;
use warnings FATAL => 'all';

WriteMakefile(
    NAME                => 'Handel::Storage::RDBO',
    AUTHOR              => 'Christopher H. Laco <claco@chrislaco.com>',
    VERSION_FROM        => 'lib/Handel/Storage/RDBO.pm',
    ABSTRACT_FROM       => 'lib/Handel/Storage/RDBO.pm',
    PL_FILES            => {},
    PREREQ_PM           => {
        'Handel'           => '1.0',
        'Rose::DB'         => '0.732',
        'Rose::DB::Object' => '0.759',
        'Clone'            => '0',
        'Scalar::Util'     => '0'
    },
    NO_META             => 1,
    dist                => {
        PREOP           => 'pod2text lib/Handel/Storage/RDBO.pm > $(DISTVNAME)/README',
    },    
    clean               => { FILES => 'Handel-Storage-RDBO-* t/var' },
);
