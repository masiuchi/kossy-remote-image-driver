use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'RemoteImageDriver',
    VERSION_FROM  => 'lib/RemoteImageDriver.pm',
    PREREQ_PM     => {
        'Kossy' =>  '0.38',
    },
    MIN_PERL_VERSION => '5.008001'
);

