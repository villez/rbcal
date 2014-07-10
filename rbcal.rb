#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#
# (c) Ville Siltanen 2013-2014

require "date"
require "optparse"

class RbCal

  # formatting constants; not really meant to be customized, but depending
  # on terminal window size, 2 or 4 columns may be useful as well
  WEEK_ROW_LEN = 25
  EMPTY_WEEK_ROW = " " * WEEK_ROW_LEN
  DEFAULT_COLUMNS = 3
  EMPTY_DAY_STR = "   "

  def initialize(start_month, end_month, year)
    @start_month = @month = start_month
    @end_month = end_month
    @year = year
    @special_dates = SpecialDate.new(year)
  end


  def print_cal
    print_month_range(DEFAULT_COLUMNS)
    puts
  end

  def print_month_range(cols = DEFAULT_COLUMNS)
    (@start_month..@end_month).each_slice(cols) do |months|
      month_str_arrays = get_months_as_str_array(months)
      print_month_str_arrays_side_by_side(month_str_arrays)
      puts if months.last != @end_month  # extra newline only in between, not after last month row
    end
  end

  def get_months_as_str_array(months)
    month_str_arrays = []
    months.each do |i|
      @month = i
      @first_day_of_month = Date.new(@year, @month, 1)
      month_str_arrays << month_grid_str.split("\n")
    end
    month_str_arrays
  end

  def print_month_str_arrays_side_by_side(month_str_arrays)
    # different months may have different amount of weeks -> rows, need max to print
    linecount = month_str_arrays.map { |ma| ma.size }.max
    combined_month_str = ""

    (0...linecount).each do |i|           # into each line
      month_str_arrays.each do |ma|       # get a week string from each month
        combined_month_str << ma.fetch(i, EMPTY_WEEK_ROW)
        combined_month_str << "  " unless ma == month_str_arrays.last
      end
      combined_month_str << "\n"
    end
    puts combined_month_str
  end

  def month_grid_str
    month_header + weekday_header + week_rows_for_month
  end

  def month_header
    @first_day_of_month.strftime("%B %Y").center(WEEK_ROW_LEN) + "\n"
  end

  def weekday_header
    "Wk  Mo Tu We Th Fr Sa Su \n"
  end

  def week_rows_for_month
    current_day = @first_day_of_month
    month_weeks_grid_str = ""
    while current_day.month == @month
      current_week_str, next_week_first_day = week_row(current_day)
      month_weeks_grid_str << current_week_str
      current_day = next_week_first_day
    end
    month_weeks_grid_str
  end

  def week_row(current_day)
    current_week_str = week_number_str(current_day)
    current_week_str << EMPTY_DAY_STR * (current_day.cwday - 1) # padding if 1st not Monday
    (0..(7 - current_day.cwday)).each do |i|
      if current_day.month == @month
        current_week_str << day_str(current_day)
        current_day += 1
      else # ran over to next month, in the middle of the week
        current_week_str << EMPTY_DAY_STR * (7 - i)  # add padding to end of last week in month
        break
      end
    end

    current_week_str << "\n"
    [current_week_str, current_day] # when month still unfinished, current_day = 1st day of next week
  end

  def week_number_str(current_day)
    colorize_string("%02d  " % current_day.cweek, :green)
  end

  def day_str(date)
    daystr = "%02d " % date.day
    if date == Time.now.to_date
      daystr = colorize_string(daystr, :blue)
    elsif @special_dates.holiday?(date.day, date.mon)
      daystr = colorize_string(daystr, :red)
    elsif @special_dates.personal_hilight?(date.day, date.mon)
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


class SpecialDate
  # predefined fixed holiday dates to highlight - [day, month]
  # Note! based on the Finnish calendar
  FIXED_HOLIDAYS = [[1, 1], [6, 1], [1, 5], [6, 12], [24, 12], [25, 12], [26, 12]]
  CONFIG_FILE = File.join(ENV["HOME"], ".rbcal")

  def initialize(year)
    @year = year
    @holidays = init_holidays
    @personal_hilights = init_personal_hilights
  end

  def holiday?(day, month)
    @holidays.include?([day, month])
  end

  def personal_hilight?(day, month)
    @personal_hilights.include?([day, month])
  end

  def init_holidays
    holidays = FIXED_HOLIDAYS
    easter_val = easter  # calculate only once
    ascension_day = easter_val + 39
    holidays <<
      day_month(easter_val) <<
      day_month(easter_val - 2) <<          # Good Friday
      day_month(easter_val - 1) <<          # Easter Saturday
      day_month(easter_val + 1) <<          # Monday after Easter
      day_month(ascension_day) <<       # Finnish "Helatorstai"
      day_month(midsummer_eve) <<
      day_month(midsummer_eve + 1) <<
      day_month(all_hallows_day)
  end

  def init_personal_hilights
    hilights = read_hilight_days_from_config_file
    hilights += standard_hilight_days
    hilights
  end

  def read_hilight_days_from_config_file
    hilights = []
    return hilights unless File.exist? CONFIG_FILE
    File.open(CONFIG_FILE, 'r') do |f|
      f.each_line do |line|
        next if line.start_with?("#") || line =~ /^\s*\n$/
        day_str, month_str, year_str = line.split(' ')
        hilights << [day_str.to_i, month_str.to_i] if !year_str || year_str.to_i == @year
      end
    end
    hilights
  end

  def standard_hilight_days
    [] << day_month(mothers_day) <<
      day_month(fathers_day) <<
      day_month(daylight_saving_start) <<
      day_month(daylight_saving_end)
  end

  def day_month(date)
    [date.day, date.month]
  end

  def midsummer_eve # the Friday between 19-25 June
    (19..25).each do |x|
      d = Date.new(@year, 6, x)
      return d if d.friday?
    end
  end

  def all_hallows_day # the Saturday between Oct 31 and Nov 6
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
  USAGE_MSG = "Usage: rbcal -h | [[month | start_month-end_month] year]"

  def parse_month_param(param)
    if /\A(?<start_month_param>\d\d?)-(?<end_month_param>\d\d?)\Z/ =~ param
      start_month = int_from_str(start_month_param)
      end_month = int_from_str(end_month_param)
    else
      start_month = end_month = int_from_str(param)
    end
    unless month_params_legal?(start_month, end_month)
      abort USAGE_MSG 
    end
    [start_month, end_month]
  end


  def int_from_str(str)
    Integer(str, 10)    # always use decimal, even for zero-prefix forms like 05
  rescue ArgumentError  # if str is not numeric => invalid argument, unrecoverable error
    abort USAGE_MSG
  end

  def month_params_legal?(start_month, end_month)
    (1..12).include?(start_month) &&
      (1..12).include?(end_month) &&
      start_month <= end_month
  end

  def main
    OptionParser.new do |opts|
      opts.banner = USAGE_MSG
      opts.on("-h", "--help", "Show this message") { puts opts; exit }
    end.parse!

    case ARGV.size
    when 0                                      
      # no params = current month only
      start_month = end_month = Time.now.month
      year = Time.now.year
    when 1
      # month range for current year: dd-dd, or a year
      if ARGV[0] =~ /\d{1,2}-\d{1,2}/
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
        
    RbCal.new(start_month, end_month, year).print_cal
  end
end

Runner.new.main
