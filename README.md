# vscal

A command line calendar viewer written in Ruby, doing the same basic
task as the Unix cal/ncal utilities.

## Features

Doesn't support all the options in the stock Unix/Linux/OS X versions,
such as handling Julian calendars, etc. However, has a few
additional features:

 * displaying an arbitrary month range that may go across different years
 * always show week numbers to the left
 * use ANSI colors to highlight the current date, public holidays,
   and other "notable" dates, like daylight saving time changes
 * support for configuring your own list of dates to highlight via a
   configuration file (~/.vscal)

The public holidays etc. are currently only shown based on the rules
for the *Finnish* calendar; there are going to be some differences
in other countries.


## Usage Examples

    vscal                  # current month
    vscal +N               # current month and N next months
    vscal 2015             # full year, Jan-Dec 2015
    vscal 7-10             # July-October for current year
    vscal 10-05            # Oct this year - May next year
    vscal 05 2014          # May 2014
    vscal 03/2015          # March 2015
    vscal 10-12 2013       # Oct-Dec 2013
    vscal 03-04/2016       # Mar-Apr 2016
    vscal 10 2013 05 2014  # Oct 2013 - May 2014
    vscal 11/2014 10/2015  # Nov 2014 - Oct 2015
    vscal 09/2014-02/2015  # Sep 2014 - Feb 2015

So the supported parameter combinations are:

* no parameters: display the current month only
* a number preceded by +: display current month and the N following months
* a single parameter: the year to display in full
* two numbers separated by a dash: a month range; if the first month
  is bigger than the second, wrap over to the next year
* two numbers separated by a space: month and year
* two dash-separated numbers + 3rd number: month range and year
* four numbers: month firstyear month lastyear (also support
  month/firstyear month/lastyear and mont/firstyear-month/lastyear)


## Installing

Ruby 2.x recommended; may work with 1.9.x but no longer tested. Does
*NOT* work with Ruby 1.8.7, mainly because the program utilizes the
`Date` stdlib class heavily, and some of the features used aren't
available in 1.8.7, which has been end-of-lifed anyway.

Currently moving to a Ruby gem format is a work in progress. You
*should* be able to install the program by cloning this repository,
building them gem with `gem build vscal.gemspec` and then `gem
install`ing the resulting vscal-<version>.gem file, but as the
conversion from a standalone script into a Gem is a new development,
there may be some hiccups.


## The Configuration File

The `~/.vscal` configuration file is a simple text file that lists
dates that should be highlighted in the calendar display. It's
optional, so if you don't wish to configure custom highlight dates
with it, you can safely ignore it or even remove it.

Since Ruby gems don't allow "post-install" scripts without
workarounds, the example configuration file is nowadays not
automatically copied into the home directory. There may be a solution
to this later, but for now, either copy the example file by hand to
`~/.vscal` or just create it from scratch. 

In the configuration file, dates are listed each on their own row with
the format `day month [year]`, meaning that the year is optional, and
if it's not provided, the date is highlighted for all years. If the
year is provided, the date is highlighted only for that specific year.

There isn't any kind of annotation for the dates, because in the
calendar display there's no room for showing any additional
information. Also, this feature isn't really meant to be a replacement
for a full-blown calendar app with appointments, alerts etc., just
simple reminders that certain dates are "noteworthy". It's of course
up to you to decide if and how to use this.


## Future Development Items

Possible enhancements, no concrete implementation plan or schedule at
the moment: 

 * options to customize color output or turn it off completely
 * other output formatting options, e.g. specifying the number of
   columns, suppressing week number display, ...
 * option to turn off highlighting holidays etc.
 * if add more command-line options: separate configuration files for
   the options and for the highlighted dates?
 * supporting holidays for other countries than Finland - not likely
   to happen

## Copyright & License

(c) Ville Siltanen 2013-2016; MIT license.
