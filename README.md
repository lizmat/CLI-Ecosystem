[![Actions Status](https://github.com/lizmat/CLI-Ecosystem/actions/workflows/test.yml/badge.svg)](https://github.com/lizmat/CLI-Ecosystem/actions)

NAME
====

CLI::Ecosystem - Raku® Programming Language Ecosystem Inspector

SYNOPSIS
========

```bash
$ ecosystem dis Foo --verbose
Distributions that match Foo and their frequency
--------------------------------------------------------------------------------
App::Football (6x)
Foo (3x)
WebService::FootballData (5x)
```

DESCRIPTION
===========

CLI::Ecosystem installs the `ecosystem` CLI script that allows introspection of Raku Programming Language's Ecosystem Content Storage.

Named arguments that are always available: --ecosystem the Ecosystem Content Storage to be used. rea | fez | p6c | cpan, default: rea --verbose boolean, show extended information, default: False

Named arguments that are available in search and informational queries: --ver the :ver<> value to use, default: none --auth the :auth<> value to use, default: none --api the :api<> value to use, default: 0 --from the :from<> value to use, default: Raku

Search queries (also looks in description): us use-target <string> use targets for optional string di distro <string> distribution names for optional string i identity <string> identities for optional string

Informational queries: de dependencies string dependencies for given string re reverse-dependencies string reverse dependencies for given string m meta string key(s) META information for given string

Other queries: ri river <--top> most referenced modules unr unresolvable <--from> unresolvable dependencies, include <:from>? unv unversioned distributions without valid version

All subcommands can be shortened as long as they are unique.

AUTHOR
======

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/CLI-Ecosystem . Comments and Pull Requests are welcome.

If you like this module, or what I’m doing more generally, committing to a [small sponsorship](https://github.com/sponsors/lizmat/) would mean a great deal to me!

COPYRIGHT AND LICENSE
=====================

Copyright 2022 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

