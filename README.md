A simple replacement for the Unix cal command, written in Ruby. 

Doesn't support all the options in the stock Unix/Linux/OS X versions,
but does have a few additional features:

 * displaying an arbitrary month range (within the same year)
 * always show week numbers to the left
 * use ANSI colors to highlight the current date, public holidays,
   and other notable dates

The public holidays etc. are currently only shown based on the
rules for the Finnish calendar, and there are most probably some
at least some differences in other countries.

Note! The install.sh script is very very basic and doesn't do 
any error checking, don't use blindly.


Licensed under the MIT license, see the file LICENSE for details.
