# rbcal

A Unix cal/ncal command replacement, written in Ruby. 

## Features

Doesn't support all the options in the stock Unix/Linux/OS X versions,
such as handling Julian calendars, etc. However, it does have a few
additional potentially useful features:

 * displaying an arbitrary month range (currently only within the same year)
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

## Installing

Requirements: Ruby 1.9.x+/2.x - does *NOT* work with Ruby 1.8.7. The
exact version cutoff not determined. The reason is mainly because the
program uses the `Date` stdlib class heavily, and some of the features
aren't available in 1.8.7, and it has been end-of-lifed anyway so I
have no interest in putting in extra effort to support it.

There is a simple shell script to install the program for use,
`install.sh` However it's very basic and just copies the main script
into ~/bin/rbcal and the example configuration file into ~/.rbcal but
doesn't do much error checking, except not overwriting a previous
configuration file. Use carefully, and make sure the ~/bin directory
exists beforehand. You can easily do the same thing manually.


## Future Features

No active further development planned, but possible enhancements
could include:

 * options to suppress/customize color output
 * other output formatting options (e.g. specifying the number of columns)
 * possibility to display a month range across different years,
   such as 11-2013 - 03-2014


## Copyright & License

(c) Ville Siltanen 2013-2014; MIT license.
