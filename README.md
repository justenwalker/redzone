# RedZone - Generate BIND zone files from simple YAML syntax

Introduction
------------

RedZone is a command-line utility for generating BIND DNS zone files from a YAML file. The tools follows the
UNIX philosophy and therefore does not attempt to do anything besides this.

RedZone was inspired by Daniel P. Berrange's [NoZone](http://search.cpan.org/~danberr/NoZone-1.0/lib/NoZone.pm) i
script which does something very similar in Perl.
The notable differences are:
 - Added support for reverse-dns generation
 - Removed zone inheritance, opting instead to just
   use a common section from which all zones inherit details.
 - No generation of named.conf.

Disclaimer
----------

This gem was just released (pre 1.0) and probably doesn't have everything (or anything) you want yet.

During pre 1.0, things may change that break backwards compatibility between releases. Most likely these breaking
changes would be related to the YAML file syntax.

### Current TODO List

- More test coverage for existing features

Installation
------------

`gem install redzone`

Usage
-----

```
RedZone commands:
  redzone generate DIR    # Generates a bind database files into the given directory.
  redzone help [COMMAND]  # Describe available commands or one specific command
  redzone version         # Shows the current version of redzone

Options:
  [--zones=ZONES]  # RedZone zone file. (Default: /etc/redzone/zones.yml)
```

### Generating zone databases

- Create a zones.yml file (See [zones.yml.example]) in `/etc/redzone`
- Execute `redzone generate /var/named`
- Each zone and reverse record database should be present in /var/named

For example, if your zone.yml file is like the zones.yml.example file
then the resulting db files are:
- `0.0.0.0.0.0.0.0.0.0.c.f.ip6.arpa.db`
- `1.168.192.in-addr.arpa.db`
- `32.12.in-addr.arpa.db`
- `9.8.7.6.4.3.2.1.1.0.0.2.ip6.arpa.db`
- `qa.redzone.com.db`
- `redzone.com.db`

How to Contribute
-----------------

### Running the tests

    $ bundle
    $ bundle exec rake spec

### Installing locally

    $ bundle
    $ [bundle exec] rake install

### Reporting Issues

Please include a reproducible test case.

License
-------

Copyright (c) 2013 Justen Walker.

Released under the terms of the MIT License. For further information, please see the file [LICENSE.md].
