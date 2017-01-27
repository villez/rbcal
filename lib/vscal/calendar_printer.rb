module VsCal
  # This class takes care of printing the calendar based on
  # the starting & ending month and year parameters; utilizes the
  # SpecialDates class for detecting dates to highlight
  class CalendarPrinter
    # print formatting constants; not meant to be customized, but
    # depending on terminal window size, 2 or 4 columns might be usable
    WEEK_ROW_WIDTH = 25
    COLUMNS = 3
    EMPTY_WEEK_ROW = " " * WEEK_ROW_WIDTH
    EMPTY_DAY = "   "
    MONTH_GUTTER = "  "

    def initialize(start_month, end_month, read_config = true)
      @month_range = []
      @special_dates = {}
      @read_config = read_config
      initialize_parameters(start_month, end_month)
    end

    # Set the internal parameters based on the given args for
    # the start & end months for the calendar display. The complexity
    # comes from handling month ranges spanning multiple years.
    def initialize_parameters(start_month, end_month)
      @special_dates[start_month.year] = VsCal::SpecialDates.new(start_month.year, @read_config)

      m = start_month.month
      y = start_month.year
      while y < end_month.year || (y == end_month.year && m <= end_month.month)
        @month_range << Date.new(y, m)
        if m == 12
          m = 1
          y += 1
          @special_dates[y] = VsCal::SpecialDates.new(y, @read_config)
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

    # print the grids for the given months side by side in order
    def print_months_side_by_side(month_slice)
      # get the grid for each month into an array of array strings
      month_grids = month_slice.map { |month| month_display_grid(month) }

      # calculate the max number of printable lines and add empty line padding
      # as needed so every grid has the same number of lines to print
      max_line_count = month_grids.map(&:size).max
      month_grids = month_grids.map { |month| month + [EMPTY_WEEK_ROW] * (max_line_count - month.size) }

      # combine the different month grids so they can be printed side by side
      merged_month_grids = month_grids.transpose.map { |row| row.join(MONTH_GUTTER) }.join("\n")

      puts merged_month_grids
      puts
    end

    def first_day_of_month(month)
      Date.new(month.year, month.month, 1)
    end

    # month grid = month name + weekday names + the actual day grid
    def month_display_grid(month)
      [month_header(month), weekday_header] + weeks_for_month(month)
    end

    # produce the name of the month centered for the header
    def month_header(month)
      first_day_of_month(month).strftime("%B %Y").center(WEEK_ROW_WIDTH)
    end

    def weekday_header
      "Wk  Mo Tu We Th Fr Sa Su "
    end

    # produce the printable strings for the weeks in the given month
    def weeks_for_month(month)
      weeks = []
      day = first_day_of_month(month)
      while day.month == month.month
        weeks << week_display(day)
        day = first_day_of_next_week(day)
      end
      weeks
    end

    # return the data for a week given the month and the starting day, which
    # for the first week in the month can be any weekday, so empty padding may
    # be needed at the beginning
    def week_display(start_day)
      week_number_display(start_day) +
        beginning_of_week_padding(start_day) +
        days_for_week(start_day)
    end

    # helper method to get the last day of the week containing the given day
    def last_day_of_week(start_day)
      start_day + (7 - start_day.cwday)
    end

    # helper method to get the first day of the *next* week given a day
    def first_day_of_next_week(day)
      last_day_of_week(day) + 1
    end

    # produce the displayable version of the week number for a given day
    def week_number_display(day)
      colorize_string(format("%02d  ", day.cweek), :green)
    end

    # produce enough empty padding for a week when a month doesn't
    # start on a Monday
    def beginning_of_week_padding(start_day)
      EMPTY_DAY * (start_day.cwday - 1)
    end

    # collect all the days for a week into a single string; if the month
    # rolls over during the week, add empty padding for those days
    def days_for_week(start_day)
      (start_day..last_day_of_week(start_day)).reduce("") do |days, day|
        days << (day.month == start_day.month ? day_display(day) : EMPTY_DAY)
      end
    end

    # produce the display string for a day; colorize if it's the current date,
    # a holiday, or a date listed in the configuration file as one to be highlighted
    def day_display(date)
      formatted_day = format("%02d ", date.day)
      if date == Date.today
        formatted_day = format_today(formatted_day)
      elsif @special_dates[date.year].holiday?(date)
        formatted_day = format_holiday(formatted_day)
      elsif @special_dates[date.year].personal_hilight?(date)
        formatted_day = format_hilight(formatted_day)
      end
      formatted_day
    end

    # helper methods to produce the highlighted versions of
    # the day numbers to display; currently ANSI-colored but could
    # use other techniques as well
    def format_today(str)
      colorize_string(str, :blue)
    end

    def format_holiday(str)
      colorize_string(str, :red)
    end

    def format_hilight(str)
      colorize_string(str, :yellow)
    end


    # returns an ANSI colored version of the given string
    def colorize_string(str, color)
      # not a complete list of colors, but currently only need these 4
      fg_colors = { red: 31, green: 32, yellow: 33, blue: 34 }
      "\033[#{fg_colors[color]}m#{str}\033[0m"
    end
  end
end
