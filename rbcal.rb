#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#
# A command-line calendar program like cal/ncal in Unixes
# but with some added (and subtracted) features. See README.md
# for a full description.
# 
# (c) Ville Siltanen 2013-2015

require "date"

# helper struct to hold a month and a year (but no day)
Month = Struct.new(:month, :year)

# This class takes care of printing the calendar based on
# the starting & ending month and year parameters; utilizes the
# SpecialDates class for detecting dates to highlight 
class RbCal
  # print formatting constants; not meant to be customized, but
  # depending on terminal window size, 2 or 4 columns might be usable
  WEEK_ROW_LEN = 25
  EMPTY_WEEK_ROW = " " * WEEK_ROW_LEN
  COLUMNS = 3
  EMPTY_DAY = "   "
  MONTH_GUTTER = "  "

  def initialize(start_month, end_month)
    @month_range = []
    @special_dates = {}
    initialize_parameters(start_month, end_month)
  end

  def initialize_parameters(start_month, end_month)
    @special_dates[start_month.year] = SpecialDates.new(start_month.year)
    
    m = start_month.month
    y = start_month.year
    while y < end_month.year || (y == end_month.year &&  m <= end_month.month)
      @month_range << Month.new(m, y)
      if m == 12
        m = 1
        y += 1
        @special_dates[y] = SpecialDates.new(y)
      else
        m += 1
      end
    end
  end

  def print_calendar
    @month_range.each_slice(COLUMNS) do |month_slice|
      print_months_side_by_side(month_slice)
    end
  end

  def print_months_side_by_side(month_slice)
    # get the grid for each month into an array of array strings
    month_grids = month_slice.map { |month| month_display_grid(month) }

    # calculate the max number of lines in the months
    line_count = month_grids.map(&:size).max

    # merge lines from each month to print side by side
    combined_month_string = (0...line_count).map do |line_idx|
      combined_week_row_for_months(month_grids, line_idx)
    end.join
    
    puts combined_month_string + "\n"
  end

  def combined_week_row_for_months(month_grids, index)
    week_row = ""
    
    month_grids.each do |month|
      week_row << month.fetch(index, EMPTY_WEEK_ROW)
      week_row << MONTH_GUTTER unless month == month_grids.last
    end
    week_row << "\n"
  end


  def first_day_of_month(month)
    Date.new(month.year, month.month, 1)
  end

  def month_display_grid(month)
    [month_header(month), weekday_header] + weeks_for_month(month)
  end

  def month_header(month)
    first_day_of_month(month).strftime("%B %Y").center(WEEK_ROW_LEN)
  end

  def weekday_header
    "Wk  Mo Tu We Th Fr Sa Su "
  end

  def weeks_for_month(month)
    weeks = []
    day = first_day_of_month(month)
    while day.month == month.month
      wk = week_display(month, day)
      day = wk[:first_of_next_week]
      weeks << wk[:week_display_string]
    end
    weeks
  end

  def week_display(month, start_day)
    last_day = start_day + (7 - start_day.cwday)
    
    { week_display_string: week_number_display(start_day) + beginning_of_week_padding(start_day) +
      days_for_week(month, start_day, last_day),
      first_of_next_week: last_day + 1 }
  end

  def week_number_display(current_day)
    colorize_string(format("%02d  ", current_day.cweek), :green)
  end

  def beginning_of_week_padding(start_day)
    EMPTY_DAY * (start_day.cwday - 1)
  end

  def days_for_week(month, start_day, last_day)
    (start_day..last_day).reduce("") do |days, day|
      days << (day.month == month.month ? day_display(day) : EMPTY_DAY)
    end
  end

  def day_display(date)
    formatted_day = format("%02d ", date.day)
    if date == Time.now.to_date
      formatted_day = format_today(formatted_day)
    elsif @special_dates[date.year].holiday?(date)
      formatted_day = format_holiday(formatted_day)
    elsif @special_dates[date.year].personal_hilight?(date)
      formatted_day = format_hilight(formatted_day)
    end
    formatted_day
  end

  def format_today(str)
    colorize_string(str, :blue)
  end

  def format_holiday(str)
    colorize_string(str, :red)
  end

  def format_hilight(str)
    colorize_string(str, :yellow)
  end
  

  def colorize_string(str, color)
    # not a complete list of colors, but currently only need these 4
    fg_colors = { red: 31, green: 32, yellow: 33, blue: 34 }
    "\033[#{fg_colors[color]}m#{str}\033[0m"
  end
end

# a utility class for handling dates to be highlighted, including reading
# from the config file (~/.rbcal), storing common Finnish holidays, and
# calculating the dates for moving holidays per year according to predefined
# rules
# Each instance is *per year*, so when displaying multiple years in a single
# run, the class must be instantiated separately for each of the years
class SpecialDates
  CONFIG_FILE = File.join(ENV["HOME"], ".rbcal")

  # predefined fixed holidays (same date every year) to highlight
  # the format is [day, month]
  # Note! based on the Finnish calendar!
  FIXED_HOLIDAYS = [[1, 1],   # New Year
                    [6, 1],   # Epiphany
                    [1, 5],   # Labor day
                    [6, 12],  # Finnish independence day
                    [24, 12], # Christmas days
                    [25, 12],
                    [26, 12]]

  def initialize(year)
    @year = year
    @holidays = holidays
    @personal_hilights = hilight_days_from_config_file + common_finnish_hilight_days
  end

  def holiday?(date)
    @holidays.include?(date)
  end

  def personal_hilight?(date)
    @personal_hilights.include?(date)
  end

  def holidays
    holidays = FIXED_HOLIDAYS.map { |day| Date.new(@year, day[1], day[0]) }
    easter_date = easter  # calculate easter location only once, use many times below
    holidays + [
                easter_date,
                easter_date - 2,      # Good Friday
                easter_date - 1,      # Easter Saturday
                easter_date + 1,      # Monday after Easter
                easter_date + 39,     # Ascension Day, Finnish "Helatorstai"
                midsummer_eve,
                midsummer_eve + 1,
                all_hallows_day
               ]
  end

  def hilight_days_from_config_file
    hilights = []

    return hilights unless File.exist?(CONFIG_FILE)
    
    File.readlines(CONFIG_FILE).each do |line|
      next if line !~ /^\d{1,2}\s\d{1,2}(\s\d{1,4})?.*$/
      day, month, year = line.split(' ').map(&:to_i)
      year = @year if year.nil?
      date = Date.new(year, month, day) rescue next  # protect from malformed config
      hilights << date
    end
    
    hilights
  end

  def common_finnish_hilight_days
    [
     mothers_day,
     fathers_day,
     daylight_saving_start,
     daylight_saving_end
    ]
  end

  def midsummer_eve   # the Friday between 19-25 June
    (19..25).each do |x|
      d = Date.new(@year, 6, x)
      return d if d.friday?
    end
  end

  def all_hallows_day  # the Saturday between Oct 31 and Nov 6
    d = Date.new(@year, 10, 31)
    return d if d.saturday?

    (1..6).each do |x|
      d = Date.new(@year, 11, x)
      return d if d.saturday?
    end
  end

  def mothers_day # second Sunday in May
    second_sunday_in_month(5)
  end

  def fathers_day # second Sunday in November
    second_sunday_in_month(11)
  end

  def daylight_saving_start # last Sunday in March
    last_sunday_in_month(3)
  end

  def daylight_saving_end # last Sunday in October
    last_sunday_in_month(10)
  end

  def second_sunday_in_month(month)
    (8..14).each do |x|
      d = Date.new(@year, month, x)
      return d if d.sunday?
    end
  end

  def last_sunday_in_month(month)
    31.downto(25).each do |x|
      d = Date.new(@year, month, x)
      return d if d.sunday?
    end
  end

  def easter
    # http://en.wikipedia.org/wiki/Computus#Anonymous_Gregorian_algorithm
    # There are lots of alternative Easter calculation algorithms,
    # but not interested in the details here and just treating this as a black box.

    a = @year % 19
    b, c = @year.divmod(100)
    d, e = b.divmod(4)
    f = (b + 8) / 25
    g = (b - f + 1) / 3
    h = (19 * a + b - d - g + 15) % 30
    i, k = c.divmod(4)
    l = (32 + 2*e + 2*i - h - k) % 7
    m = (a + 11*h + 22*l) / 451
    month = (h + l - 7*m + 114) / 31
    day = ((h + l - 7*m + 114) % 31) + 1

    Date.new(@year, month, day)
  end
end

# parsing and validity checking the command-line arguments
class ParamParser
  USAGE_MSG = <<-EOM
    Usage:
    rbcal                  # display current month
    rbcal 2015             # display full year, Jan-Dec 2015
    rbcal 7-10             # display July-October for current year
    rbcal 10-05            # display Oct this year - May next year
    rbcal 05 2014          # display May 2014
    rbcal 10-12 2013       # display Oct-Dec 2013
    rbcal 10 2013 05 2014  # display Oct 2013 - May 2014
    rbcal 11/2014 10/2015  # display Nov 2014 - Oct 2015
    rbcal 09/2014-02/2015  # display Sep 2014 - Feb 2015
  EOM

  # regular expressions matching the supported command-line 
  RE_MONTH_RANGE = /\A(?<first_month>\d\d?)-(?<second_month>\d\d?)\Z/
  RE_SINGLE_YEAR = /\A(?<year>\d{1,})\Z/
  RE_MONTH_AND_YEAR = /\A(?<month>\d\d?)\s(?<year>\d{1,})\Z/
  RE_MONTH_RANGE_AND_YEAR = /\A(?<first_month>\d\d?)\-(?<second_month>\d\d?)\s(?<year>\d{1,})\Z/
  RE_TWO_MONTHS_TWO_YEARS = /\A(?<first_month>\d\d?)[\s\/](?<first_year>\d{1,})[\s-](?<second_month>\d\d?)[\s\/](?<second_year>\d{1,})\Z/
  
  def parse_command_line_parameters
    # this is actually redundant, as any non-numeric params
    # will fail the later checks for valid month/date parameters,
    # and the usage message will be printed; still, maybe cleaner to
    # have this explicit 
    abort USAGE_MSG if ARGV[0] == "-h" || ARGV[0] == "--help"

    case ARGV.join(' ')
    when /\A\s*\Z/
      start_month = end_month = Month.new(Time.now.month, Time.now.year)
    when RE_SINGLE_YEAR
      start_month = Month.new(1, Regexp.last_match(:year).to_i)
      end_month = Month.new(12, Regexp.last_match(:year).to_i)
    when RE_MONTH_RANGE
      first_month = Regexp.last_match(:first_month).to_i
      second_month = Regexp.last_match(:second_month).to_i
      start_month = Month.new(first_month, Time.now.year)
      if first_month < second_month
        end_month = Month.new(second_month, Time.now.year)
      else
        end_month = Month.new(second_month, Time.now.year + 1)
      end
    when RE_MONTH_AND_YEAR
      month = Regexp.last_match(:month).to_i
      year = Regexp.last_match(:year).to_i
      start_month = end_month = Month.new(month, year)
    when RE_MONTH_RANGE_AND_YEAR
      first_month = Regexp.last_match(:first_month).to_i
      second_month = Regexp.last_match(:second_month).to_i
      year = Regexp.last_match(:year).to_i
      start_month = Month.new(first_month, year)
      end_month = Month.new(second_month, year)
    when RE_TWO_MONTHS_TWO_YEARS
      first_month = Regexp.last_match(:first_month).to_i
      second_month = Regexp.last_match(:second_month).to_i
      first_year = Regexp.last_match(:first_year).to_i
      second_year = Regexp.last_match(:second_year).to_i
      start_month = Month.new(first_month, first_year)
      end_month = Month.new(second_month, second_year)
    else
      abort USAGE_MSG
    end
    
    abort USAGE_MSG unless legal_month_range?(start_month, end_month)

    [ start_month, end_month ]
  end

  def legal_month_range?(start_month, end_month)
    (1..12).include?(start_month.month) && 
      (1..12).include?(end_month.month) &&
      start_month.year <= end_month.year &&
      (start_month.month <= end_month.month || start_month.year < end_month.year)
  end
end

month_range = ParamParser.new.parse_command_line_parameters
RbCal.new(month_range.first, month_range.last).print_calendar


