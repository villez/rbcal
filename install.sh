#!/bin/sh
# installing the calendar script as an executable script
# under the user's home directory

# no error handling implemented or customization options implemented yet

echo "installing as ~/bin/rbcal"

cp ./rbcal.rb ~/bin/rbcal
chmod a+x ~/bin/rbcal
