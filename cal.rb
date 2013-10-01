#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'date'

class CLICal

  def initialize(month, year)
    @month = month
    @year = year
    @first_day = Date.new(@year, @month, 1)
    init_holidays
    init_notables
  end

  def print_cal
    print_month_header
    print_weekday_header
    print_calendar_grid
  end

  def print_month_header
    puts @first_day.strftime("%B %Y").center(24)
  end

  def print_weekday_header
    puts "Wk  Mo Tu We Th Fr Sa Su"
  end

  def print_calendar_grid
    day = @first_day
    while day.month == @month
      next_week_first = print_week(day)
      day = next_week_first
    end
    puts
  end

  def print_week(current)
    printf "\033[32m%02d\033[0m  ", current.cweek
    weekday = current.cwday
    days_before = weekday - 1
    days_after = 7 - weekday
    print "   " * days_before
    (0..days_after).each do
      if current.month != @month
        break
      end
      print_day(current)
      current += 1
    end
    print "\n"
    current  # the first day of the next week at this point
  end

  def print_day(date)
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
    print daystr
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
if ARGV.size == 2
  month = Integer(ARGV[0], 10)  # 2nd param: leading zero doesn't mean octal
  year = Integer(ARGV[1], 10)
elsif ARGV.size == 1
  flag_full_year = true
  year = Integer(ARGV[0], 10)
else
  month = Time.now.to_date.month
  year = Time.now.to_date.year
end

if flag_full_year
  (1..12).each do |m|
    cal = CLICal.new(m, year)
    cal.print_cal
  end
else
  cal = CLICal.new(month, year)
  cal.print_cal
end
