# NAME

Dist::Zilla::Plugin::EnsureNewVersion - Ensure at release time that every $VERSION is newer than what is indexed

# VERSION

version 0.001

# SYNOPSIS

In your `dist.ini`:

    [EnsureNewVersion]

# DESCRIPTION

This is a [Dist::Zilla](https://metacpan.org/pod/Dist::Zilla) plugin that, at release time, checks all your modules'
`$VERSION` declarations against the PAUSE index. If any version is not new,
the release is aborted.

The `:InstallModules` filefinder is used to find files to check.

# CONFIGURATION OPTIONS

There are no configuration options at this time.

# SUPPORT

Bugs may be submitted through [the RT bug tracker](https://rt.cpan.org/Public/Dist/Display.html?Name=Dist-Zilla-Plugin-EnsureNewVersion)
(or [bug-Dist-Zilla-Plugin-EnsureNewVersion@rt.cpan.org](mailto:bug-Dist-Zilla-Plugin-EnsureNewVersion@rt.cpan.org)).
I am also usually active on irc, as 'ether' at `irc.perl.org`.

# SEE ALSO

- [foo](https://metacpan.org/pod/foo)

# AUTHOR

Karen Etheridge <ether@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Karen Etheridge.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
