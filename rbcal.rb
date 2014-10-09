#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#
# A command-line calendar program like cal/ncal in Unixes
# but with some added (and subtracted) features. See README.md
# for a full description.
# 
# (c) Ville Siltanen 2013-2014

require "date"

class RbCal

  # print formatting constants; not really meant to be customized;
  # depending on terminal window size, 2 or 4 columns might be useful/usable as well
  WEEK_ROW_LEN = 25
  EMPTY_WEEK_ROW = " " * WEEK_ROW_LEN
  DEFAULT_COLUMNS = 3
  EMPTY_DAY_STR = "   "
  MONTH_GUTTER = "  "

  def initialize(start_month, end_month, year)
    @month_range = start_month..end_month
    @year = year
    @special_dates = SpecialDates.new(year)
  end

  def print_cal(columns = DEFAULT_COLUMNS)
    @month_range.each_slice(columns) do |month_slice|
      print_months_side_by_side(month_slice)
      puts
    end
  end

  def print_months_side_by_side(month_slice)
    month_grids = month_slice.map { |month| month_grid_str(month).split("\n") } 
    week_line_range = (0...month_grids.map(&:size).max)
    combined_month_string = week_line_range.map do |line_idx|
      combined_week_row_for_months(month_grids, month_slice, line_idx)
    end.join
    puts combined_month_string
  end

  def combined_week_row_for_months(month_grids, month_slice, index)
    week_row = ""
    
    month_grids.each do |month|
      week_row << month.fetch(index, EMPTY_WEEK_ROW)
      week_row << MONTH_GUTTER unless month == month_grids.last
    end
    week_row << "\n"
  end


  def first_day_of_month(month)
    Date.new(@year, month, 1)
  end

  def month_grid_str(month)
    month_header(month) + weekday_header + week_rows_for_month(month)
  end

  def month_header(month)
    first_day_of_month(month).strftime("%B %Y").center(WEEK_ROW_LEN) + "\n"
  end

  def weekday_header
    "Wk  Mo Tu We Th Fr Sa Su \n"
  end

  def week_rows_for_month(month)
    week_str = ""
    current_day = first_day_of_month(month)
    while current_day.month == month
      current_week_str, current_day = process_week(month, current_day)
      week_str << current_week_str
    end
    week_str
  end

  def process_week(month, current_day)
    week_str = ""
    week_str << week_number_str(current_day)
    week_str << EMPTY_DAY_STR * (current_day.cwday - 1) # padding if 1st not Monday
    (0..(7 - current_day.cwday)).each do |i|
      if current_day.month == month
        week_str << day_str(current_day)
        current_day += 1
      else # ran over to next month in the middle of the week
        week_str << EMPTY_DAY_STR * (7 - i)  # add padding to end of last week in month
        break
      end
    end

    week_str << "\n"
    [week_str, current_day] # when month still unfinished, current_day = 1st day of next week
  end

  def week_number_str(current_day)
    colorize_string("%02d  " % current_day.cweek, :green)
  end  

  def day_str(date)
    daystr = "%02d " % date.day
    if date == Time.now.to_date
      daystr = colorize_string(daystr, :blue)
    elsif @special_dates.holiday?(date)
      daystr = colorize_string(daystr, :red)
    elsif @special_dates.personal_hilight?(date)
      daystr = colorize_string(daystr, :yellow)
    end
    daystr
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
  
  # predefined fixed holiday dates to highlight - [day, month]
  # Note! based on the Finnish calendar
  FIXED_HOLIDAYS = [[1, 1], [6, 1], [1, 5], [6, 12], [24, 12], [25, 12], [26, 12]]
  CONFIG_FILE = File.join(ENV["HOME"], ".rbcal")

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
      next if line.start_with?("#") || line =~ /^\s*\n$/
      day, month, year = line.split(' ').map(&:to_i)
      year = @year if year.nil? || year == 0
      hilights << Date.new(year, month, day)
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


class Runner
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
      (1..12).include?(end_month) &&
      start_month <= end_month
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
      start_month = end_month = Time.now.month
      year = Time.now.year
    when 1
      # month range for current year: dd-dd, or a year
      if ARGV[0] =~ RE_MONTH_RANGE_PARAM
        start_month, end_month = parse_month_param(ARGV[0])
        year = Time.now.year
      else # year
        start_month = 1
        end_month = 12
        year = int_from_str(ARGV[0])
      end
    when 2
      # two params = month(s), year
      start_month, end_month = parse_month_param(ARGV[0])
      year = int_from_str(ARGV[1])
    else
      # too many parameters
      abort USAGE_MSG
    end

    [start_month, end_month, year]
  end

  def main
    RbCal.new(*parse_command_line_parameters).print_cal
  end
end

Runner.new.main
