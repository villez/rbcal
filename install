#!/bin/sh
# installing the calendar script as an executable script
# under ~/bin and the configuration file as ~/.rbcal


echo "installing binary as ~/bin/rbcal"

cp ./rbcal.rb ~/bin/rbcal
chmod a+x ~/bin/rbcal

if [ -f "$HOME/.rbcal" ]; then
    echo "~/.rbcal exists already, not overwriting"
    exit
else
    echo "installing an example config file as ~/.rbcal"
    cp ./.rbcal-example ~/.rbcal
fi
