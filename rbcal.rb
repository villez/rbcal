#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#
# A command-line calendar program like cal/ncal in Unixes
# but with some added (and subtracted) features. See README.md
# for a full description.
# 
# (c) Ville Siltanen 2013-2014

require "date"

# helper struct to held a month with year
Month = Struct.new(:month, :year)

# The class that takes care of printing the calendar based on
# the starting & ending month and year parameters; utilizes the
# SpecialDates class for detecting dates to highlight 
class RbCal

  # print formatting constants; not really meant to be customized;
  # depending on terminal window size, 2 or 4 columns might be useful/usable as well
  WEEK_ROW_LEN = 25
  EMPTY_WEEK_ROW = " " * WEEK_ROW_LEN
  DEFAULT_COLUMN_AMOUNT = 3
  EMPTY_DAY = "   "
  MONTH_GUTTER = "  "

  def initialize(start_month, end_month)
    @month_range = []
    @special_dates = {}
    @special_dates[start_month.year] = SpecialDates.new(start_month.year)
    m = start_month.month
    y = start_month.year
    while y < end_month.year || (y == end_month.year &&  m <= end_month.month)
      @month_range << Month.new(m, y)
      unless m == 12
        m = m + 1
      else
        m = 1
        y = y + 1
        @special_dates[y] = SpecialDates.new(y)
      end
    end
  end

  def print_calendar(column_amount = DEFAULT_COLUMN_AMOUNT)
    @month_range.each_slice(column_amount) do |month_slice|
      print_months_side_by_side(month_slice)
    end
  end

  def print_months_side_by_side(month_slice)
    month_grids = month_slice.map { |month| month_display_grid(month).split("\n") }
    week_line_range = (0...month_grids.map(&:size).max)
    combined_month_string = week_line_range.map do |line_idx|
      combined_week_row_for_months(month_grids, line_idx)
    end.join
    puts combined_month_string
    puts
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
    month_header(month) + weekday_header + weeks_for_month(month)
  end

  def month_header(month)
    first_day_of_month(month).strftime("%B %Y").center(WEEK_ROW_LEN) + "\n"
  end

  def weekday_header
    "Wk  Mo Tu We Th Fr Sa Su \n"
  end

  def weeks_for_month(month)
    weeks = ""
    day = first_day_of_month(month)
    while day.month == month.month
      week, day = week_display(month, day)
      weeks << week
    end
    weeks
  end

  def week_display(month, day)
    week = ""
    week << week_number_display(day)
    week << EMPTY_DAY * (day.cwday - 1) # padding if 1st not Monday
    (0..(7 - day.cwday)).each do |i|
      if day.month == month.month
        week << day_display(day)
        day += 1
      else # ran over to next month in the middle of the week
        week << EMPTY_DAY * (7 - i)  # add padding to end of last week in month
        break
      end
    end

    week << "\n"
    [week, day] # when month still unfinished, day = 1st day of next week
  end

  def week_number_display(current_day)
    colorize_string("%02d  " % current_day.cweek, :green)
  end  

  def day_display(date)
    formatted_day = "%02d " % date.day
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
  USAGE_MSG = "Usage: rbcal [[month | start_month-end_month] year]"

  RE_MONTH_RANGE_PARAM = /\A(?<start_month_param>\d\d?)-(?<end_month_param>\d\d?)\Z/

  def parse_month_param(param)
    if RE_MONTH_RANGE_PARAM =~ param
      start_month = int_from_str(Regexp.last_match(:start_month_param))
      end_month = int_from_str(Regexp.last_match(:end_month_param))
    else
      start_month = end_month = int_from_str(param)
    end
    
    abort USAGE_MSG unless legal_month_range?(start_month, end_month)

    [start_month, end_month]
  end


  def int_from_str(str)
    Integer(str, 10)    # always use decimal, even for zero-prefix forms like 05
  rescue ArgumentError  # if str is not numeric => invalid argument, unrecoverable error
    abort USAGE_MSG
  end

  def legal_month_range?(start_month, end_month)
    (1..12).include?(start_month) &&
      (1..12).include?(end_month) 
  end

  def parse_command_line_parameters
    # this is actually redundant, as any non-numeric params
    # will fail the later checks for valid month/date parameters,
    # and the usage message will be printed; still, maybe cleaner to
    # have this explicit 
    abort USAGE_MSG if ARGV[0] == "-h" || ARGV[0] == "--help"

    case ARGV.size
    when 0                                      
      # no params => current month only
      start_month = end_month = Month.new(Time.now.month, Time.now.year)
    when 1
      # month range (dd-dd), or a year
      if ARGV[0] =~ RE_MONTH_RANGE_PARAM
        this_year = Time.now.year
        first_month, last_month = parse_month_param(ARGV[0])
        start_month = Month.new(first_month, this_year)
        if (first_month < last_month)
          end_month = Month.new(last_month, this_year)
        else
          end_month = Month.new(last_month, this_year + 1)
        end
      else # year
        year = int_from_str(ARGV[0])
        start_month = Month.new(1, year)
        end_month = Month.new(12, year)
      end
    when 2
      # two params = month(s), year
      first_month, last_month = parse_month_param(ARGV[0])
      year = int_from_str(ARGV[1])
      start_month = Month.new(first_month, year)
      end_month = Month.new(last_month, year)
    else
      # too many parameters
      abort USAGE_MSG
    end

    [start_month, end_month]
  end
end

month_range = ParamParser.new.parse_command_line_parameters
RbCal.new(*month_range).print_calendar


