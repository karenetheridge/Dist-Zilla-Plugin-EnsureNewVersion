use strict;
use warnings FATAL => 'all';

use Test::More;
use if $ENV{AUTHOR_TESTING}, 'Test::Warnings';
use Test::DZil;
use Test::Fatal;
use Path::Tiny;

my $tzil = Builder->from_config(
    { dist_root => 't/does-not-exist' },
    {
        add_files => {
            path(qw(source dist.ini)) => simple_ini(
                [ GatherDir => ],
                [ 'EnsureNewVersion' ],
            ),
            path(qw(source lib Foo.pm)) => "package Foo;\n\$Foo::VERSION = 1.0;\n1;\n",
            path(qw(source lib Bar.pm)) => "package Bar;\nour \$VERSION = 2.0;\n1;\n",
            path(qw(source lib Baz.pm)) => "package Baz;\nour \$VERSION = 3.0;\npackage Boop;\nour \$VERSION = 4.0;\n1;\n",
        },
    },
);

$tzil->chrome->logger->set_debug(1);
is(
    exception { $tzil->build },
    undef,
    'build proceeds normally',
) or diag 'saw log messages: ', explain $tzil->log_messages;

done_testing;
