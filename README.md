# rbcal

A command line calendar viewer written in Ruby, doing the same basic
task as the Unix cal/ncal utilities.

## Features

Doesn't support all the options in the stock Unix/Linux/OS X versions,
such as handling Julian calendars, etc. However, has a few
additional features:

 * displaying a month range (currently only within the same year)
 * always show week numbers to the left
 * use ANSI colors to highlight the current date, public holidays,
   and other "notable" dates, like daylight saving time changes
 * support for configuring your own list of dates to highlight via a
   configuration file (~/.rbcal)

The public holidays etc. are currently only shown based on the rules
for the *Finnish* calendar; there are going to be some differences
in other countries.


## Usage Examples

    rbcal               # display current month
	rbcal 05 2014       # display May 2014
	rbcal 10-12 2013    # display Oct-Dec 2013
	rbcal 7-10          # display July-October for current year
    rbcal 2015          # display full year, Jan-Dec 2015

So the supported parameter combinations are:

* no parameters: display the current month only
* a single parameter: the year to display in full
* two numbers separated by a dash: a month range for the current year
  (first number must be smaller than the second one)
* two numbers separated by a space: month and year
* two dash-separated numbers + 3rd number: month range and year


## Installing

Ruby 2.x recommended; may work with 1.9.x but no longer tested. Does
*NOT* work with Ruby 1.8.7, mainly because the program utilizes the
`Date` stdlib class heavily, and some of the features used aren't
available in 1.8.7, which has been end-of-lifed anyway.

There is a simple shell script to install the program for use,
`install`. However it's very basic and just copies the main script
into `~/bin/rbcal` and the example configuration file into `~/.rbcal`.

The install script isn't extremely robust, but it does check that the
`~/bin` directory exists and doesn't overwrite a previous
configuration file (`~/.rbcal`). You can also easily do the same thing
manually and choose where to put the script, what to name it, whether
to include the config file or not, etc.


## The Configuration File

The `~/.rbcal` configuration file is a simple text file that lists
dates that should be highlighted in the calendar display. It's
optional, so if you don't wish to configure custom highlight dates
with it, you can safely leave it out or remove it.

The dates are listed each on their own row with the format `day month
[year]`, meaning that the year is optional, and if it's not provided,
the date is highlighted for all years. If the year is provided, the
date is highlighted only for that specific year.

There isn't any kind of annotation for the dates, because in the
calendar display there's no room for showing any additional
information. Also, this feature isn't really meant to be a replacement
for a full-blown calendar app with appointments, alerts etc., just
simple reminders that certain dates are "noteworthy" in some way.


## Future Development Items

Possible enhancements, no concrete implementation plan or schedule at
the moment: 

 * displaying a month range across different years,
   such as 11-2013 - 03-2014
 * options to customize color output or turn it off completely
 * other output formatting options, e.g. specifying the number of
   columns, leaving out week numbers, ...
 * making the configuration file format and parsing more robust,
   e.g. verifying that end-of-line # comments work in all
   combinations, etc.


## Copyright & License

(c) Ville Siltanen 2013-2014; MIT license.
