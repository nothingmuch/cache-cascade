use ExtUtils::MakeMaker;

WriteMakefile(
	'NAME'         => 'Cache::Cascade',
	'VERSION_FROM' => 'lib/Cache/Cascade.pm',
	'PREREQ_PM'    => {
		'Moose'         => '0.05',
		'Test::use::ok' => '0'
	},
	'INSTALLDIRS' => 'site',
	'EXE_FILES'   => [],
	'PL_FILES'    => {},
	'SIGN'        => 1,
);
