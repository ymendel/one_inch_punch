# one_inch_punch

## Description

`one_inch_punch` is meant as a generally data- and interface-compatible alternative
to Ara T. Howard's `punch` gem. The main benefits will be greater understandability,
test coverage, and usage outside of merely command-line situations.

  * Punch: Good enough
  * One-inch punch: Smaller, more effective

## Features/Problems

  * Can load and write `.punch.yml` data compatibly with Ara's `punch` gem
  * Things you may expect from a time-tracking program, like punching in and out and getting time data
  * The ability to be punched in to multiple projects at once, because double-billing is awesome
  * More, since this is unfinished

## SYNOPSIS:

``` ruby
require 'punch'

Punch.load
Punch.status('my project')  # => 'out'
Punch.in('my project')
Punch.status('my project')  # => 'in'
# do some work
Punch.out('my project')
Punch.out?('my project')    # => true
Punch.write
```

or!

    $ punch in proj
    $ echo 'working, really'
    $ punch out proj
    $ punch status

or!

``` ruby
require 'punch'

proj = Punch.new('my project')
proj.status                     # => 'out'
proj.in
proj.status                     # => 'in'
# do some work
proj.out
proj.out?                       # => true
Punch.write
```

## Requirements

  * A reason to track time
  * Ruby

## Install

    gem install one_inch_punch

## Thanks

  * Ara T. Howard, for making `punch` in the first place
  * Kevin Barnes, for the name suggestion
  * Bruce Lee, for having been a bad-ass
  * The Kool-Aid Man, for busting through my wall. Oh yeah!
