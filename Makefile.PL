# $Id$
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Handel::Storage::RDBO',
    AUTHOR              => 'Christopher H. Laco <claco@chrislaco.com>',
    VERSION_FROM        => 'lib/Handel/Storage/RDBO.pm',
    ABSTRACT_FROM       => 'lib/Handel/Storage/RDBO.pm',
    PL_FILES            => {},
    PREREQ_PM           => {
        'Handel'           => '1.0',
        'Rose::DB'         => '0',
        'Rose::DB::Object' => '0'
    },
    NO_META             => 1,
    dist                => {
        COMPRESS        => 'gzip -9f',
        SUFFIX          => 'gz',
        PREOP           => 'pod2text lib/Handel/Storage/RDBO.pm > $(DISTVNAME)/README',
    },
    clean               => { FILES => 'Handel-Storage-RDBO-* t/var' },
);
