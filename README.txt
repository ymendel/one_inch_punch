= one_inch_punch

== DESCRIPTION:

one_inch_punch is meant as a generally data- and interface-compatible alternative
to Ara T. Howard's punch gem. The main benefits will be greater understandability,
test coverage, and usage outside of merely command-line situations.

Punch: Good enough
One-inch punch: Smaller, more effective

== FEATURES/PROBLEMS:

* Can load and write .punch.yml data compatibly with Ara's punch gem
* Can punch in and out of projects (including creating a project by punching in)
* Can query project status
* Can delete a project
* Can list project data
* Can give total time for a project
* Can be used command-line
* Command-line output is less ugly
* More, since this is unfinished

== SYNOPSIS:

  require 'punch'
  
  Punch.load
  Punch.status('my project')  # => 'out'
  Punch.in('my project')
  Punch.status('my project')  # => 'in'
  # do some work
  Punch.out('my project')
  Punch.out?('my project')    # => true
  Punch.write
  
  or!
  
  $ punch in proj
  $ echo 'working, really'
  $ punch out proj
  $ punch status
  
  or!
  
  require 'punch'
  
  proj = Punch.new('my project')
  proj.status                     # => 'out'
  proj.in
  proj.status                     # => 'in'
  # do some work
  proj.out
  proj.out?                       # => true
  Punch.write

== REQUIREMENTS:

* A reason to track time
* Ruby

== INSTALL:

* gem install one_inch_punch

== THANKS:

  * Ara T. Howard, for making punch in the first place
  * Kevin Barnes, for the name suggestion
  * Bruce Lee, for having been a bad-ass
  * The Kool-Aid Man, for busting through my wall. Oh yeah!
