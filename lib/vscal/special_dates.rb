module VsCal
  # a utility class for handling dates to be highlighted, including reading
  # from the config file (~/.vscal), storing common Finnish holidays, and
  # calculating the dates for moving holidays per year according to predefined
  # rules
  # Each instance is *per year*, so when displaying multiple years in a single
  # run, the class must be instantiated separately for each of the years
  class SpecialDates
    CONFIG_FILE = File.join(ENV["HOME"], ".vscal")

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

    def initialize(year, read_config = true)
      @year = year
      @holidays = holidays
      @personal_hilights = common_finnish_hilight_days
      @personal_hilights += hilight_days_from_config_file if read_config
    end

    def holiday?(date)
      @holidays.include?(date)
    end

    def personal_hilight?(date)
      @personal_hilights.include?(date)
    end

    # initialize the holiday data based on both the fixed configuration (for dates
    # that are always the same every year, like Christmas) and the data that needs to
    # be calculated separately for each year based on some rules, such as Easter
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

    # read and parse dates from the configuration file
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
      l = (32 + 2 * e + 2 * i - h - k) % 7
      m = (a + 11 * h + 22 * l) / 451
      month = (h + l - 7 * m + 114) / 31
      day = ((h + l - 7 * m + 114) % 31) + 1

      Date.new(@year, month, day)
    end
  end
end
