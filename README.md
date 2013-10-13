A simple replacement for the Unix cal command, written in Ruby. 

Doesn't support all the options in the stock Unix/Linux/OS X versions,
but does have a few additional features:

 * displaying an arbitrary month range (within the same year)
 * always show week numbers to the left
 * use ANSI colors to highlight the current date, public holidays,
   and other "notable" dates
 * supports configuring your own list of dates to highlight, although
   currently only by editing the script

The public holidays etc. are currently only shown based on the rules
for the Finnish calendar, and there are going to be some differences
in other countries.

Note! The install.sh script is very basic, it just copies the main
script into ~/bin/rbcal and doesn't do any error checking, so use carefully.

(c) Ville Siltanen 2013; Licensed under the MIT license, see LICENSE.
