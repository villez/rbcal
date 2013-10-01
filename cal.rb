#!/usr/bin/env ruby

require 'date'

class CLICal

  DAYS_IN_MONTH = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

  def initialize
    @date = Time.now.to_date
    #@date = Date.new(2012, 9, 7)
    @first_day = Date.new(@date.year, @date.month, 1)
    @days_in_month = get_days_in_month
  end

  def print
    print_month_header
    print_weekday_header
    print_calendar_grid
  end

  def print_month_header
    puts @date.strftime("%B %Y").center(24)
  end

  def print_weekday_header
    puts "Wk# Mo Tu We Th Fr Sa Su"
  end

  def print_calendar_grid
    print_week(@first_day)
    puts
    puts "#{@days_in_month} days this month"
  end

  def print_week(first_day)
    first_week = first_day.cweek
    printf "%02d  ", first_week
    monday = @first_day -= (@first_day.jd) % 7
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
cal.print
