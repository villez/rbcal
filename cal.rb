#!/usr/bin/env ruby

require 'date'

class CLICal

  DAYS_IN_MONTH = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

  def initialize
    #@date = Time.now.to_date
    @date = Date.new(2012, 2, 12)
    @first_day = Date.new(@date.year, @date.month, 1)
    @days_in_month = get_days_in_month
  end

  def print_cal
    print_month_header
    print_weekday_header
    print_calendar_grid
  end

  def print_month_header
    puts @date.strftime("%B %Y").center(24)
  end

  def print_weekday_header
    puts "Wk  Mo Tu We Th Fr Sa Su"
  end

  def print_calendar_grid
    day = @first_day
    while day.month == @date.month
      prev = print_week(day)
      day = prev
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
      if current.month != @date.month
        break
      end
      if current == Time.now.to_date
        daystr = sprintf "\033[34m%02d\033[0m ", current.day
      else
        daystr = sprintf "%02d ", current.day
      end
      print daystr
      current += 1
    end
    print "\n"
    current
  end

  def get_days_in_month
    days = DAYS_IN_MONTH[@date.month - 1]
    if @date.month == 2 && @date.leap?
      days += 1
    end
    days
  end
  
end

cal = CLICal.new
cal.print_cal
