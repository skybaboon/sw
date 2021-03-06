Usage
=====

``sw`` is a simple command line based stopwatch utility.

It is designed to be particularly useful for people who need to enter starting
and finishing times into a timesheet - in terms of hours and minutes - but also
need a calculation - in terms of decimal fractions - of the total number of
hours they have worked.

Typical usage for building a timesheet:

- At the start of the working day, enter ``sw reset`` (to ensure the stopwatch
  is reset to zero), followed by ``sw start``.
- When you go on a lunch break or other break, enter ``sw stop``.
- When you come back from a break, enter ``sw start`` again.
- When you finish your day, enter ``sw reset``.

On being reset - or on entering ``sw stats`` - the program will output a
summary of starting and stopping times, the total hours elapsed ignoring breaks,
the total duration of breaks, and the total hours elapsed net of breaks.

For a summary of usage, enter ``sw help``.

Dependencies
============

You need ``ruby``.

Installing
==========

On Unix-like systems, you can install ``sw`` from the command line as follows:

- ``chmod +x sw.rb``
- ``sudo cp sw.rb /usr/local/bin/sw`` (or copy to a different location as you
  see fit).

**NOTE** ``sw`` will also create a file called ``.sw.yml`` in your home folder,
the first time it is run. If a file with this name already exists, *it will be
clobbered*.

Uninstalling
============

You need to remove both the ``sw`` script (from ``/usr/local/bin``, or wherever
you installed it), and the ``.sw.yml`` data file that the program creates in
your home directory.

Known shortcomings
==================

- The program does not make a swap or backup of the ``.sw.yml`` data file. It
  probably should.
- It hasn't been properly tested.
- There is no way of manually entering start and finishing times. (Although you
  could always just open up ``.sw.yml`` and change the times therein - being
  careful to preserve the prescribed format for times. Note the first time in
  the list is the time the stopwatch was initially started, after the previous
  reset. The second time shows the first time it was stopped. Thereafter, times
  alternate between starting and stopping times.)

Contact
=======

You are welcome to contact me about this project at:

software@matthewharvey.net
