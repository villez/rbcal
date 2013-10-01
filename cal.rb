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
      print_whole_year
    else
      print_single_month
    end
  end

  def print_whole_year
    (1..12).each_slice(3) do |month_triplet|
      @month = month_triplet[0]
      @first_day = Date.new(@year, @month, 1)
      left_month = month_header + weekday_header + calendar_grid
      left_month_array = left_month.split("\n")
      @month = month_triplet[1]
      @first_day = Date.new(@year, @month, 1)
      center_month = month_header + weekday_header + calendar_grid
      center_month_array = center_month.split("\n")
      @month = month_triplet[2]
      @first_day = Date.new(@year, @month, 1)
      right_month = month_header + weekday_header + calendar_grid
      right_month_array = right_month.split("\n")

      linecount = [right_month_array.size, center_month_array.size, left_month_array.size].max
      empty = " " * 25
      combined_month_str = ""
      
      (0...linecount).each do |i|
        combined_month_str << left_month_array.fetch(i, empty)
        combined_month_str << "  "
        combined_month_str << center_month_array.fetch(i, empty)
        combined_month_str << "  "
        combined_month_str << right_month_array.fetch(i, empty)
        combined_month_str << "\n"
      end

      puts combined_month_str
      puts
    end
  end

  def print_single_month
    @first_day = Date.new(@year, @month, 1)
    print month_header + weekday_header + calendar_grid
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

  def week_row(current)
    str = sprintf "\033[32m%02d\033[0m  ", current.cweek
    weekday = current.cwday
    days_before = weekday - 1
    days_after = 7 - weekday
    str << "   " * days_before
    padding_day_count = 0
    (0..days_after).each do |i|
      if current.month != @month
        padding_day_count = 7 - i
        break
      end
      str << day_str(current)
      current += 1
    end

    str << "   " * padding_day_count
    str << "\n"
    [str, current]  # current = the first day of the next week at this point
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

  def find_midsummer_friday
    (19..25).each do |x| 
      if Date.new(@year, 6, x).friday?
        return [x, 6]
      end
    end
  end

  def find_pyhainpaiva
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

  def find_mothers_day
    (8..14).each do |x|
      if Date.new(@year, 5, x).sunday?
        return [x, 5]
      end
    end
  end

  def find_fathers_day
    (8..14).each do |x|
      if Date.new(@year, 11, x).sunday?
        return [x, 11]
      end
    end
  end

  def calculate_easter
    y = @year

    # just reuse an algorithm; don't care about making this
    # readable as the algos themselves are obscure by default
    n = y % 19
    c = y / 100
    k = (c - 17) / 25
    i = (c - c/4 -(c-k)/3 + 19 * n + 15) % 30
    i = i -(i/28) * (1 - (i/28) * (29/(i + 1)) * ((21 - n)/11))
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
