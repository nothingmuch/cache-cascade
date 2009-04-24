use ExtUtils::MakeMaker;

WriteMakefile(
	'NAME'         => 'Cache::Cascade',
	'VERSION_FROM' => 'lib/Cache/Cascade.pm',
	'PREREQ_PM'    => {
		'Mouse' => '0.04',
		'Any::Moose' => 0,
		'Test::use::ok' => '0',
		'namespace::clean' => '0.08',
	},
	'INSTALLDIRS' => 'site',
	'EXE_FILES'   => [],
	'PL_FILES'    => {},
	'SIGN'        => 1,
);
