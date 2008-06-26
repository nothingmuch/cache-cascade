use ExtUtils::MakeMaker;

WriteMakefile(
	'NAME'         => 'Cache::Cascade',
	'VERSION_FROM' => 'lib/Cache/Cascade.pm',
	'PREREQ_PM'    => {
		'Mouse' => '0.04',
		'Squirrel' => 0,
		'Test::use::ok' => '0'
	},
	'INSTALLDIRS' => 'site',
	'EXE_FILES'   => [],
	'PL_FILES'    => {},
	'SIGN'        => 1,
);
