#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'date'

class CLICal

  WEEK_ROW_LEN = 25
  EMPTY_WEEK_ROW = " " * WEEK_ROW_LEN
  DEFAULT_YEAR_COLUMNS = 3
  EMPTY_DAY_STR = "   "

  def initialize(month, year, flag_full_year = false)
    @month = month
    @year = year
    @flag_full_year = flag_full_year
    init_holidays
    init_notables
  end

  def print_cal
    if @flag_full_year
      print_whole_year(DEFAULT_YEAR_COLUMNS)
    else
      print_single_month
    end
    puts
  end

  def print_whole_year(cols = DEFAULT_YEAR_COLUMNS)
    (1..12).each_slice(cols) do |months|
      month_str_arrays = get_months_as_str_array(months)
      print_month_str_arrays_side_by_side(month_str_arrays)
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
  
  def print_single_month
    @first_day_of_month = Date.new(@year, @month, 1)
    print month_grid_str
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
    sprintf "\033[32m%02d\033[0m  ", current_day.cweek
  end
  
  def day_str(date)
    daystr = sprintf "%02d ", date.day
    if date == Time.now.to_date
      daystr = sprintf "\033[34m%02d\033[0m ", date.day
    end
    if @holidays.include? [date.day, date.mon]
      daystr = sprintf "\033[31m%02d\033[0m ", date.day
    end
    if @notables.include? [date.day, date.mon]
      daystr = sprintf "\033[33m%02d\033[0m ", date.day
    end
    daystr
  end

  def init_holidays
    @holidays = [[1, 1], [6, 1], [1, 5], [6, 12], [24, 12], [25, 12], [26, 12]]
    @holidays << find_midsummer_friday
    easter = calculate_easter
    good_friday = easter - 2
    easter_monday = easter + 1
    helatorstai = easter + 39
    @holidays << [good_friday.day, good_friday.month]
    @holidays << [easter_monday.day, easter_monday.month]
    @holidays << [helatorstai.day, helatorstai.month]
    @holidays << find_pyhainpaiva
  end

  def init_notables
    @notables = [[12, 2], [14, 4], [2, 8], [8, 8], [24, 10], [12, 12]]
    @notables << find_mothers_day
    @notables << find_fathers_day
  end

  def find_midsummer_friday # the Friday between 19-25 June
    (19..25).each do |x|
      # note: in newer Rubies there are convenience methods like friday?, saturday? etc
      # but those don't seem to be included in 1.8.7 which is OS X default still, so
      # for a bit of compatibility, decided not to use them here although they look nicer
      if Date.new(@year, 6, x).friday?
        return [x, 6]
      end
    end
  end

  def find_pyhainpaiva # the Saturday between Oct 31 and Nov 6
    if Date.new(@year, 10, 31).saturday?
      return [31, 10]
    else
      (1..6).each { |x| if Date.new(@year, 11, x).saturday? then return [x, 11] end }
    end
  end

  def find_mothers_day # second Sunday in May
    (8..14).each { |x| if Date.new(@year, 5, x).sunday? then return [x, 5] end }
  end

  def find_fathers_day # second Sunday in November
    (8..14).each { |x| if Date.new(@year, 11, x).sunday? then return [x, 11] end }
  end

  def calculate_easter
    y = @year

    # black box easter algorithm; don't care about making this
    # readable as all the algorithms are rather obscure
    n = y % 19
    c = y / 100
    k = (c - 17) / 25
    i = (c - c/4 -(c-k)/3 + 19 * n + 15) % 30
    i = i - (i/28) * (1 - (i/28) * (29/(i + 1)) * ((21 - n)/11))
    j = (y + y/4 + i + 2 - c + c/4) % 7
    l = i - j
    
    m = 3 + (l + 40) / 44;
    d = l + 28 - 31 * (m / 4);
    
    Date.new(y, m, d)

  end
end


def usage
  STDERR.puts "usage: "
  STDERR.puts "mcal [[month] year]"
  exit
end  

#
# runner
#
begin
  case ARGV.size
  when 0
    month = Time.now.month
    year = Time.now.year
    flag_full_year = false
  when 1 
    month = nil
    year = Integer(ARGV[0], 10)   # 2nd param: leading zero doesn't mean octal
    flag_full_year = true
  when 2
    month = Integer(ARGV[0], 10)  
    year = Integer(ARGV[1], 10)
    flag_full_year = false
  else
    usage
  end
rescue
  usage
end

cal = CLICal.new(month, year, flag_full_year)
cal.print_cal

