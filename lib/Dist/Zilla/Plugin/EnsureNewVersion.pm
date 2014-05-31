use strict;
use warnings;
package Dist::Zilla::Plugin::EnsureNewVersion;
# ABSTRACT: Ensure at release time that every $VERSION is newer than what is indexed
# vim: set ts=8 sw=4 tw=78 et :

use Moose;
with
    'Dist::Zilla::Role::BeforeRelease',
    'Dist::Zilla::Role::FileFinderUser' => {
        default_finders => [ ':InstallModules' ],
    },
;
use Encode;
use HTTP::Tiny;
use JSON::MaybeXS;
use version;
use Module::Metadata;
use namespace::autoclean;

sub before_release
{
    my $self = shift;

    my $dist_provides = $self->zilla->distmeta->{provides};

    my @errors;
    foreach my $file (@{ $self->found_files })
    {
        # TODO: use Module::Metadata role, when available
        my $module_metadata = Module::Metadata->new_from_file($file->name);
        foreach my $package ($module_metadata->packages_inside)
        {
            my ($ok, $message) = $self->_has_new_version($dist_provides, $module_metadata, $package);
            $self->log_debug('checked ' . $package. ': ' . $message);
            push @errors, [ $package, $message ] if not $ok;
        }
    }

    return if not @errors;

    $self->log(join("\n", map { $_->[0] . ': ' . $_->[1] } @errors));
    $self->log_fatal('halting release');
}

# very similar to version_is_bumped in Dist::Zilla::Plugin::Test::NewVersion
# returns bool, detailed message
sub _has_new_version
{
    my ($self, $dist_provides, $module_metadata, $pkg) = @_;

    # TODO: we can also pull down the full 02packages.details.txt, and even
    # share this file with [PromptIfStale] and [CheckPrereqsIndexed]

    $self->log_debug("fetching: http://cpanidx.org/cpanidx/json/mod/$pkg");
    my $res = HTTP::Tiny->new->get("http://cpanidx.org/cpanidx/json/mod/$pkg");
    return (0, 'index could not be queried?') if not $res->{success};

    # JSON wants UTF-8 bytestreams, so we need to re-encode no matter what
    # encoding we got. -- rjbs, 2011-08-18 (in Dist::Zilla::Plugin::CheckPrereqsIndexed)
    my $payload = decode_json(Encode::encode_utf8($res->{content}));

    return (0, 'no valid JSON returned') unless $payload;

    return (1, 'not indexed') if not defined $payload->[0]{mod_vers};
    return (1, 'VERSION is not set in index') if $payload->[0]{mod_vers} eq 'undef';

    my $indexed_version = version->parse($payload->[0]{mod_vers});
    my $current_version = $module_metadata->version($pkg);

    if (not defined $current_version)
    {
        return (0, 'VERSION is not set; indexed version is ' . $indexed_version)
            if not $dist_provides or not $current_version = $dist_provides->{$pkg}{version};
    }

    return (
        $indexed_version < $current_version,
        'indexed at ' . $indexed_version . '; local version is ' . $current_version,
    );
}

__PACKAGE__->meta->make_immutable;
__END__

=pod

=head1 SYNOPSIS

In your F<dist.ini>:

    [EnsureNewVersion]

=head1 DESCRIPTION

This is a L<Dist::Zilla> plugin that, at release time, checks all your modules'
C<$VERSION> declarations against the PAUSE index. If any version is not new,
the release is aborted.

=for :stopwords filefinder

The C<:InstallModules> filefinder is used to find files to check.

=head1 CONFIGURATION OPTIONS

There are no configuration options at this time.

=for Pod::Coverage before_release

=head1 SUPPORT

=for stopwords irc

Bugs may be submitted through L<the RT bug tracker|https://rt.cpan.org/Public/Dist/Display.html?Name=Dist-Zilla-Plugin-EnsureNewVersion>
(or L<bug-Dist-Zilla-Plugin-EnsureNewVersion@rt.cpan.org|mailto:bug-Dist-Zilla-Plugin-EnsureNewVersion@rt.cpan.org>).
I am also usually active on irc, as 'ether' at C<irc.perl.org>.

=head1 SEE ALSO

=for :list
* L<foo>

=cut
