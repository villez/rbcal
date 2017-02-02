module VsCal
  # parsing and validity checking the command-line arguments
  class ParamParser
    USAGE_MSG = <<-EOM
    Usage:
    vscal                  # current month
    vscal +N               # current month and N next months
    vscal 2015             # full year, Jan-Dec 2015
    vscal 7-10             # July-October for current year
    vscal 10-05            # Oct this year - May next year
    vscal 05 2014          # May 2014
    vscal 03/2015          # March 2015
    vscal 10-12 2013       # Oct-Dec 2013
    vscal 03-04/2016       # Mar-Apr 2016
    vscal 10 2013 05 2014  # Oct 2013 - May 2014
    vscal 11/2014 10/2015  # Nov 2014 - Oct 2015
    vscal 09/2014-02/2015  # Sep 2014 - Feb 2015
  EOM

    # regular expressions matching the supported command-line
    RE_PLUS_MONTH = /\A\+(?<plus_month>\d+)\Z/
    RE_MONTH_RANGE = /\A(?<first_month>\d\d?)-(?<second_month>\d\d?)\Z/
    RE_SINGLE_YEAR = /\A(?<year>\d{1,})\Z/
    RE_MONTH_AND_YEAR = /\A(?<month>\d\d?)[\s\/](?<year>\d{1,})\Z/
    RE_MONTH_RANGE_AND_YEAR = /\A(?<first_month>\d\d?)\-(?<second_month>\d\d?)[\s\/](?<year>\d{1,})\Z/
    RE_TWO_MONTHS_TWO_YEARS = /\A(?<first_month>\d\d?)[\s\/](?<first_year>\d{1,})[\s-](?<second_month>\d\d?)[\s\/](?<second_year>\d{1,})\Z/

    # interpreting the command-line parameters to determine the month(s)
    # and year(s) for the calendar range
    def self.parse_command_line_parameters(arguments)

      # This is actually redundant, as any non-numeric params
      # will fail the later checks for valid month/date parameters,
      # but maybe cleanest to have it explicitly listed. If there were
      # more "standard" type of options, would use OptParse instead.
      abort USAGE_MSG if arguments[0] == "-h" || arguments[0] == "--help"

      # matching the command-line arguments against the regular expressions
      # defined above; the order shouldn't be significant in this case, but
      # be careful and check before rearranging!
      case arguments.join(' ')
      when /\A\s*\Z/
        start_month = end_month = Date.today
      when RE_PLUS_MONTH
        start_month = Date.today

        # the Date#>> method returns a date n months later
        end_month = start_month >> Regexp.last_match(:plus_month).to_i
      when RE_SINGLE_YEAR
        start_month = Date.new(Regexp.last_match(:year).to_i, 1)
        end_month = Date.new(Regexp.last_match(:year).to_i, 12)
      when RE_MONTH_RANGE
        first_month = Regexp.last_match(:first_month).to_i
        second_month = Regexp.last_match(:second_month).to_i
        start_month = Date.new(Date.today.year, first_month)
        if first_month < second_month
          end_month = Date.new(Date.today.year, second_month)
        else
          end_month = Date.new(Date.today.year + 1, second_month)
        end
      when RE_MONTH_AND_YEAR
        month = Regexp.last_match(:month).to_i
        year = Regexp.last_match(:year).to_i
        start_month = end_month = Date.new(year, month)
      when RE_MONTH_RANGE_AND_YEAR
        first_month = Regexp.last_match(:first_month).to_i
        second_month = Regexp.last_match(:second_month).to_i
        year = Regexp.last_match(:year).to_i
        start_month = Date.new(year, first_month)
        end_month = Date.new(year, second_month)
      when RE_TWO_MONTHS_TWO_YEARS
        first_month = Regexp.last_match(:first_month).to_i
        second_month = Regexp.last_match(:second_month).to_i
        first_year = Regexp.last_match(:first_year).to_i
        second_year = Regexp.last_match(:second_year).to_i
        start_month = Date.new(first_year, first_month)
        end_month = Date.new(second_year, second_month)
      else
        abort USAGE_MSG
      end

      abort USAGE_MSG unless legal_month_range?(start_month, end_month)

      { start: start_month, end: end_month }
    end

    def self.legal_month_range?(start_month, end_month)
      (1..12).include?(start_month.month) &&
        (1..12).include?(end_month.month) &&
        start_month.year <= end_month.year &&
        (start_month.month <= end_month.month || start_month.year < end_month.year)
    end
  end
end
