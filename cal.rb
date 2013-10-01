#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'date'

class CLICal

  def initialize(month, year, flag_full_year)
    @month = month
    @year = year
    @flag_full_year = flag_full_year
    init_holidays
    init_notables
  end

  def print_cal
    if @flag_full_year
      print_whole_year(3)
    else
      print_single_month
    end
  end

  def print_whole_year(cols = 3)
    (1..12).each_slice(cols) do |month_triplet|
      month_arrays = []
      month_triplet.each do |i|
        @month = i
        @first_day = Date.new(@year, @month, 1)
        month_arrays << month_grid_str.split("\n")
      end

      linecount = month_arrays.map { |ma| ma.size }.max
      empty = " " * 25
      combined_month_str = ""
      
      (0...linecount).each do |i|
        month_arrays.each do |ma|
          combined_month_str << ma.fetch(i, empty)
          combined_month_str << "  " unless ma == month_arrays.last
        end
        combined_month_str << "\n"
      end
      puts combined_month_str
      puts
    end
  end

  def print_single_month
    @first_day = Date.new(@year, @month, 1)
    print month_grid_str
  end

  def month_grid_str
    month_header + weekday_header + calendar_grid
  end
  
  def month_header
    @first_day.strftime("%B %Y").center(25) + "\n"
  end

  def weekday_header
    "Wk  Mo Tu We Th Fr Sa Su \n"
  end

  def calendar_grid
    day = @first_day
    str = ""
    while day.month == @month
      week_str, next_week_first = week_row(day)
      str << week_str
      day = next_week_first
    end
    str + "\n"
  end

  def week_row(current_day)
    str = sprintf "\033[32m%02d\033[0m  ", current_day.cweek
    current_weekday = current_day.cwday
    padding_before = current_weekday - 1
    str << "   " * padding_before
    days_after = 7 - current_weekday
    padding_after = 0
    (0..days_after).each do |i|
      if current_day.month != @month
        padding_after = 7 - i
        break
      end
      str << day_str(current_day)
      current_day += 1
    end

    str << "   " * padding_after  # add padding to end of last week in month
    str << "\n"
    [str, current_day]  # here current = the first day of the next week
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
      if Date.new(@year, 6, x).friday?
        return [x, 6]
      end
    end
  end

  def find_pyhainpaiva # the Saturday between Oct 31 and Nov 6
    if Date.new(@year, 10, 31).saturday?
      return [31, 10]
    else
      (1..6).each do |x|
        if Date.new(@year, 11, x).saturday?
          return [x, 11]
        end
      end
    end
  end

  def find_mothers_day # second Sunday in May
    (8..14).each do |x|
      if Date.new(@year, 5, x).sunday?
        return [x, 5]
      end
    end
  end

  def find_fathers_day # second Sunday in November
    (8..14).each do |x|
      if Date.new(@year, 11, x).sunday?
        return [x, 11]
      end
    end
  end

  def calculate_easter
    y = @year

    # black box easter algorithm; don't care about making this
    # readable as all the algorithms are rather obscure and
    # not interested in understanding them
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


#
# runner
#
case ARGV.size
when 1 
  month = nil
  year = Integer(ARGV[0], 10)   # 2nd param: leading zero doesn't mean octal
  flag_full_year = true
when 2
  month = Integer(ARGV[0], 10)  
  year = Integer(ARGV[1], 10)
  flag_full_year = false
else
  month = Time.now.to_date.month
  year = Time.now.to_date.year
  flag_full_year = false
end

cal = CLICal.new(month, year, flag_full_year)
cal.print_cal
