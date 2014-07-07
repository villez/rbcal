# rbcal

A simple replacement for the Unix cal/ncal command, written in Ruby. 

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
    rbcal 2015          # display show full year 2015

## Installing

Note: requires Ruby 1.9+ - exact version cutoff not determined, as I'm
primarily using 2.x myself. The reason is mainly because it uses the
`Date` stdlib class heavily, and some of the features aren't available
in 1.8.7. It should be feasible to implement all the same
functionality in an 1.8 compatible way, but currently I have no
interest in doing that.

Just run `./install.sh` But note! The install.sh script is very basic,
it just copies the main script into ~/bin/rbcal and the example
configuration file into ~/.rbcal but doesn't do much error checking,
except not overwriting a previous configuration file. Use carefully,
and make sure the ~/bin directory exists beforehand.


## Future Features

No active further development planned, but possible enhancements
could include:

 * options to suppress/customize color output
 * other output formatting options (e.g. specifying the number of columns)
 * possibility to display a month range across different years,
   such as 11-2013 - 03-2014


## Copyright & License

(c) Ville Siltanen 2013-2014; MIT license.
