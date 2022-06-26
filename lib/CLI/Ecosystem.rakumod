use Ecosystem:ver<0.0.16>:auth<zef:lizmat>;
use Identity::Utils:ver<0.0.10>:auth<zef:lizmat>;

sub meh($message) { exit note $message }
sub line() { say "-" x 80 }

my constant %name = (
  rea  => 'Raku Ecosystem Archive',
  fez  => 'Zef (Fez) Ecosystem Content Storage',
  p6c  => 'Original Git Ecosystem Storage',
  cpan => 'CPAN (PAUSE) Ecosystem Storage',
).Map;

my $eco;
sub eco(str $ecosystem) {
    CATCH { meh .Str }
    $eco // ($eco := Ecosystem.new(:$ecosystem))
}
my $identity;
sub resolve($ecosystem, $needle, $ver, $auth, $api, $from) {
    $identity := eco($ecosystem).resolve:
      $needle, :$ver, :$auth, :$api, :$from
}

use CLI::Version $?DISTRIBUTION, proto sub MAIN(|) is export {*}
multi sub MAIN(
  Bool() :$help      = False,  #= show this
  Str()  :$ecosystem = 'rea',  #= rea | fez | p6c | cpan
  Bool() :$verbose   = False,  #= whether to provide verbose info
) {
    eco($ecosystem);
    say "Raku® Programming Language Ecosystem Inspector ($*PROGRAM.basename() v{ Ecosystem.^ver })";
    line;
    say "Ecosystem: %name{$ecosystem} ('$ecosystem' $eco.identities.elems() identities)";
    with $eco.least-recent-release -> $from {
        say "   Period: $from - $eco.most-recent-release()";
    }
    say "  Updated: $eco.IO.modified.DateTime.Str.substr(0,19)";
    say " Meta-URL: $eco.meta-url()" if $verbose;
    line;
    say $help ?? qq:to/HELP/.chop !! "Extensive help available with --help";
Allows introspection of all aspects of a Raku Ecosystem's Content Storage.

Named arguments that are always available:
  --ecosystem  the Ecosystem Content Storage to be used.
               rea | fez | p6c | cpan, default: rea
  --verbose    boolean, show extended information, default: False

Named arguments that are available in search and informational queries:
  --ver   the :ver<>  value to use, default: none
  --auth  the :auth<> value to use, default: none
  --api   the :api<>  value to use, default: 0
  --from  the :from<> value to use, default: Raku

Search queries (also looks in description):
  us  use-target <string>  use targets for optional string
  di  distro <string>      distribution names for optional string
  i   identity <string>    identities for optional string

Informational queries:
  de  dependencies string          dependencies for given string
  re  reverse-dependencies string  reverse dependencies for given string
  m   meta string key(s)           META information for given string

Other queries:
  ri  river <--top>          most referenced modules
  unr unresolvable <--from>  unresolvable dependencies, include <:from>?
  unv unversioned            distributions without valid version

All subcommands can be shortened as long as they are unique.
HELP
    line if $help;
}

multi sub MAIN("dependencies",
  Str()   $use-target,          #= string to search for
  Str()  :$ver,                 #= :ver<> value to match
  Str()  :$auth,                #= :auth<> value to match
  Str()  :$api       = "0",     #= :api<> value to match
  Str()  :$from      = 'Raku',  #= Raku | Perl5
  Str()  :$ecosystem = 'rea',   #= rea | fez | p6c | cpan
  Bool() :$verbose   = False,   #= whether to provide verbose info
) {
    if resolve($ecosystem, $use-target, $ver, $auth, $api, $from) -> $identity {
        say $verbose
          ?? "Recursive dependencies of $identity"
          !! "Dependencies of $identity
Add --verbose for recursive depencies";
        line;
        if $eco.dependencies($identity, :recurse($verbose)) -> @identities {
            .say for @identities;
        }
        else {
            meh "No dependencies found for '$identity'";
        }
    }
    else {
        my $needle := build($use-target, :$ver, :$auth, :$api, :$from);
        meh "Could not resolve '$needle'";
    }
}

multi sub MAIN("use-target",
  Str()   $string = "",        #= string to search for
  Str()  :$ver,                #= :ver<> value to match
  Str()  :$auth,               #= :auth<> value to match
  Str()  :$api       = "0",    #= :api<> value to match
  Str()  :$from      = 'Raku', #= Raku | Perl5
  Str()  :$ecosystem = 'rea',  #= rea | fez | p6c | cpan
  Bool() :$verbose   = False,  #= whether to provide verbose info
) {
    my $needle := build $string, :$ver, :$auth, :$api, :$from;
    if eco($ecosystem).find-use-targets(
      $string, :$ver, :$auth, :$api, :$from
    ).sort(*.fc) -> @use-targets {
        say $verbose
          ?? "Use targets that match $needle and their distribution"
          !! "Use targets that match $needle
Add --verbose to also see their distribution";
        line;
        if $verbose {
            for @use-targets -> $use-target {
                my @distros = $eco.distros-of-use-target($use-target);
                say @distros == 1 && $use-target eq @distros.head
                  ?? $use-target
                  !! "$use-target (@distros[])";
            }
        }
        else {
            .say for @use-targets;
        }
    }
    else {
        meh "No use-targets found for '$needle'";
    }
}

multi sub MAIN("distro",
  Str()   $needle = "",        #= string to search for
  Str()  :$ver,                #= :ver<> value to match
  Str()  :$auth,               #= :auth<> value to match
  Str()  :$api       = "0",    #= :api<> value to match
  Str()  :$from      = 'Raku', #= Raku | Perl5
  Str()  :$ecosystem = 'rea',  #= rea | fez | p6c | cpan
  Bool() :$verbose   = False,  #= whether to provide verbose info
) {
    my $identity := build $needle, :$ver, :$auth, :$api, :$from;
    if eco($ecosystem).find-distro-names(
      $needle, :$ver, :$auth, :$api, :$from
    ).sort(*.fc) -> @names {
        say $verbose
          ?? "Distributions that match $identity and their frequency"
          !! "Distributions that match $identity
Add --verbose to also see their frequency";
        line;
        if $verbose {
            my %identities := $eco.distro-names;
            for @names -> $name {
                my $versions := %identities{$name}.elems;
                say $versions == 1
                  ?? $name
                  !! "$name ({$versions}x)";
            }
        }
        else {
            .say for @names;
        }
    }
    else {
        meh "No distributions found for '$identity'";
    }
}

multi sub MAIN("identity",
  Str()   $string = "",        #= string to search for
  Str()  :$ver,                #= :ver<> value to match
  Str()  :$auth,               #= :auth<> value to match
  Str()  :$api       = "0",    #= :api<> value to match
  Str()  :$from      = 'Raku', #= Raku | Perl5
  Str()  :$ecosystem = 'rea',  #= rea | fez | p6c | cpan
  Bool() :$verbose   = False,  #= whether to provide verbose info
) {
    my $needle := build $string, :$ver, :$auth, :$api, :$from;
    if eco($ecosystem).find-identities(
      $string, :$ver, :$auth, :$api, :$from, :all($verbose)
    ).sort(*.fc) -> @identities {
        say $verbose
          ?? "All identities that match $needle"
          !! "Most recent version of identities that match $needle
Add --verbose to see all identities";
        line;
        .say for @identities;
    }
    else {
        meh "No identities found matching '$needle'";
    }
}

multi sub MAIN("meta",
  Str()   $use-target,         #= string to search for
          *@additional,        #= additional keys to drill down to
  Str()  :$ver,                #= :ver<> value to match
  Str()  :$auth,               #= :auth<> value to match
  Str()  :$api       = "0",    #= :api<> value to match
  Str()  :$from      = 'Raku', #= Raku | Perl5
  Str()  :$ecosystem = 'rea',  #= rea | fez | p6c | cpan
  Bool() :$verbose   = False,  #= whether to provide verbose info
) {
    my $needle := build($use-target, :$ver, :$auth, :$api, :$from);
    if resolve($ecosystem, $use-target, $ver, $auth, $api, $from) -> $identity {
        if $eco.identities{$identity} -> $found {
            say $needle eq $identity
              ?? "Meta information of $needle @additional[]"
              !! "Meta information of $identity @additional[]
Resolved from $needle";
            line;
            my $data := $found;
            while @additional
              && $data ~~ Associative
              && $data{@additional.shift} -> $deeper {
                $data := $deeper;
            }
            say $eco.to-json: $data;
        }
        else {
            meh "No meta information for '$identity' found";
        }
    }
    else {
        meh "'$needle' did not resolve to a known identity";
    }
}

multi sub MAIN("reverse-dependencies",
  Str()   $use-target,         #= use target to reverse dependencies of
  Str()  :$ver,                #= :ver<> value to match, default: highest
  Str()  :$auth,               #= :auth<> value to match, default: any
  Str()  :$api       = "0",    #= :api<> value to match
  Str()  :$from      = 'Raku', #= Raku | Perl5 | bin | native
  Str()  :$ecosystem = 'rea',  #= rea | fez | p6c | cpan
  Bool() :$verbose   = False,  #= whether to provide verbose info
) {
    my $needle := build $use-target, :$ver, :$auth, :$api, :$from;
    if resolve($ecosystem, $use-target, $ver, $auth, $api, $from)
      // $needle -> $identity {
        if $verbose {
            say $needle eq $identity
              ?? "Reverse dependency identities of $identity"
              !! "Reverse dependency identities of $identity
Resolved from $needle";
            line;
            if $eco.reverse-dependencies{$identity} -> @identities {
                .say for Ecosystem.sort-identities: @identities;
            }
            else {
                meh "$identity does not appear to have any reverse dependencies";
            }
        }
        else {
            my str $short-name = short-name($identity);
            say "Reverse dependencies of $short-name
Add --verbose to see reverse dependency identies";
            line;
            if $eco.reverse-dependencies-for-short-name($short-name) -> @sn {
                .say for @sn.sort(*.fc)
            }
            else {
                meh "$short-name does not appear to have any reverse dependencies";
            }
        }
    }
    else {
        meh "$needle could not be resolved to an identity";
    }
}

multi sub MAIN("river",
  Str()  :$ecosystem = 'rea',          #= rea | fez | p6c | cpan
  Bool() :$verbose   = False,          #= whether to provide verbose info
  Int()  :$top = $verbose ?? 3 !! 20,  #= entries to list from top
) {
    say $verbose
      ?? "Top $top distributions with their dependees"
      !! "Top $top distributions and number of dependees";
    say "Add --verbose to also see the actual dependees"
      unless $verbose;
    line;
    for eco($ecosystem).river.sort( -> $a, $b {
        $b.value.elems cmp $a.value.elems
          || $a.key.fc cmp $b.key.fc
    }).head($top) {
        say "$_.key() ($_.value.elems())";
        say "  $_.value()[]\n" if $verbose
    }
}

multi sub MAIN("unresolvable",
  Str()  :$ecosystem = 'rea',  #= rea | fez | p6c | cpan
  Bool() :$from      = False,  #= include unresolvables with :from
  Bool() :$verbose   = False,  #= whether to provide verbose info
) {
    say $verbose
      ?? "All unresolvable identities"
      !! "Unresolvable identities in most recent versions only
Add --verbose to see all unresolvable identities";
    say "Add --from to also see identities with a :from<> setting"
      unless $from;
    line;
    if eco($ecosystem).unresolvable-dependencies(:all($verbose)) -> %ud {
        for %ud.keys.sort(*.fc) {
            next if !$from && from($_);
            say "$_";
            say "  $_" for %ud{$_};
            say "";
        }
    }
    else {
        say "None";
    }
}

multi sub MAIN("unversioned",
  Str()  :$ecosystem = 'rea',  #= rea | fez | p6c | cpan
  Bool() :$verbose   = False,  #= whether to provide verbose info
) {
    my @unversioned = eco($ecosystem).unversioned-distro-names;
    say "@unversioned.elems() distributions without any release with a valid version";
    if $verbose {
        line;
        .say for @unversioned;
    }
    else {
        say "Add --verbose to list the distribution names";
        line;
    }
}

use shorten-sub-commands:ver<0.0.5>:auth<zef:lizmat> &MAIN;

=begin pod

=head1 NAME

CLI::Ecosystem - Raku® Programming Language Ecosystem Inspector

=head1 SYNOPSIS

=begin code :lang<bash>

$ ecosystem dis Foo --verbose
Distributions that match Foo and their frequency
--------------------------------------------------------------------------------
App::Football (6x)
Foo (3x)
WebService::FootballData (5x)

=end code

=head1 DESCRIPTION

CLI::Ecosystem installs the C<ecosystem> CLI script that allows introspection
of Raku Programming Language's Ecosystem Content Storage.

Named arguments that are always available:

  --ecosystem  the Ecosystem Content Storage to be used.
               rea | fez | p6c | cpan, default: rea
  --verbose    boolean, show extended information, default: False

Named arguments that are available in search and informational queries:

  --ver   the :ver<>  value to use, default: none
  --auth  the :auth<> value to use, default: none
  --api   the :api<>  value to use, default: 0
  --from  the :from<> value to use, default: Raku

Search queries (also looks in description):

  us  use-target <string>  use targets for optional string
  di  distro <string>      distribution names for optional string
  i   identity <string>    identities for optional string

Informational queries:

  de  dependencies string          dependencies for given string
  re  reverse-dependencies string  reverse dependencies for given string
  m   meta string key(s)           META information for given string

Other queries:

  ri  river <--top>          most referenced modules
  unr unresolvable <--from>  unresolvable dependencies, include <:from>?
  unv unversioned            distributions without valid version

All subcommands can be shortened as long as they are unique.

=head1 AUTHOR

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/CLI-Ecosystem .
Comments and Pull Requests are welcome.

If you like this module, or what I’m doing more generally, committing to a
L<small sponsorship|https://github.com/sponsors/lizmat/>  would mean a great
deal to me!

=head1 COPYRIGHT AND LICENSE

Copyright 2022 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4
