#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#
# A command-line calendar program like cal/ncal in Unixes
# but with some added (and subtracted) features. See README.md
# for a full description.
#
# (c) Ville Siltanen 2013-2016

require "date"
require "vscal/calendar_printer"
require "vscal/param_parser"
require "vscal/special_dates"
