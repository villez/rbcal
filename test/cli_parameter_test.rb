require "minitest/autorun"
require "./rbcal"

# These tests verify that the command-line parser identifies the parameter combinations
# correctly. The actual calendar printing functionality is not included in these tests,
# but tested separately.
#
# The supported formats are:
#    rbcal                  # current month
#    rbcal +N               # current month and N next months
#    rbcal 2015             # full year, Jan-Dec 2015
#    rbcal 7-10             # July-October for current year
#    rbcal 10-05            # Oct this year - May next year
#    rbcal 05 2014          # May 2014
#    rbcal 03/2015          # March 2015
#    rbcal 10-12 2013       # Oct-Dec 2013
#    rbcal 03-04/2016       # Mar-Apr 2016
#    rbcal 10 2013 05 2014  # Oct 2013 - May 2014
#    rbcal 11/2014 10/2015  # Nov 2014 - Oct 2015
#    rbcal 09/2014-02/2015  # Sep 2014 - Feb 2015
#
# The ParamParser#parse_command_line_parameters method takes an ARGV-like array
# which is essentially the command line parameter string split on whitespace


class ParameterTest < Minitest::Test
  def test_default
    # if no parameters -> print current month
    month_range = ParamParser.new.parse_command_line_parameters([])
    assert_equal(month_range[:start].year, Date.today.year)
    assert_equal(month_range[:start].month, Date.today.month)
    assert_equal(month_range[:end].year, Date.today.year)
    assert_equal(month_range[:end].month, Date.today.month)
  end

  #    rbcal +N               # current month and N next months
  def test_plus_month
    month_range = ParamParser.new.parse_command_line_parameters(["+2"])
    assert_equal(month_range[:start].year, Date.today.year)
    assert_equal(month_range[:start].month, Date.today.month)
    assert_equal(month_range[:end].year, Date.today.year)
    assert_equal(month_range[:end].month, Date.today.month + 2)
  end

  #    rbcal 2015             # full year, Jan-Dec 2015
  def test_full_year
    month_range = ParamParser.new.parse_command_line_parameters(["2015"])
    assert_equal(month_range[:start].year, 2015)
    assert_equal(month_range[:start].month, 1)
    assert_equal(month_range[:end].year, 2015)
    assert_equal(month_range[:end].month, 12)
  end

  #    rbcal 7-10             # July-October for current year
  def test_month_range_current_year
    month_range = ParamParser.new.parse_command_line_parameters(["7-10"])
    assert_equal(month_range[:start].year, Date.today.year)
    assert_equal(month_range[:start].month, 7)
    assert_equal(month_range[:end].year, Date.today.year)
    assert_equal(month_range[:end].month, 10)
  end

  #    rbcal 10-05            # Oct this year - May next year
  def test_month_range_cross_year
    month_range = ParamParser.new.parse_command_line_parameters(["10-5"])
    assert_equal(month_range[:start].year, Date.today.year)
    assert_equal(month_range[:start].month, 10)
    assert_equal(month_range[:end].year, Date.today.year + 1)
    assert_equal(month_range[:end].month, 5)
  end

  #    rbcal 05 2014          # May 2014
  #    rbcal 03/2015          # March 2015
  def test_single_month_with_year
    month_range = ParamParser.new.parse_command_line_parameters(["05", "2014"])
    assert_equal(month_range[:start].year, 2014)
    assert_equal(month_range[:start].month, 5)
    assert_equal(month_range[:end].year, 2014)
    assert_equal(month_range[:end].month, 5)

    month_range = ParamParser.new.parse_command_line_parameters(["03/2015"])
    assert_equal(month_range[:start].year, 2015)
    assert_equal(month_range[:start].month, 3)
    assert_equal(month_range[:end].year, 2015)
    assert_equal(month_range[:end].month, 3)
  end

  #    rbcal 10-12 2013       # Oct-Dec 2013
  #    rbcal 03-04/2016       # Mar-Apr 2016
  def test_month_range_with_year
    month_range = ParamParser.new.parse_command_line_parameters(["10-12", "2013"])
    assert_equal(month_range[:start].year, 2013)
    assert_equal(month_range[:start].month, 10)
    assert_equal(month_range[:end].year, 2013)
    assert_equal(month_range[:end].month, 12)

    month_range = ParamParser.new.parse_command_line_parameters(["03-04/2016"])
    assert_equal(month_range[:start].year, 2016)
    assert_equal(month_range[:start].month, 3)
    assert_equal(month_range[:end].year, 2016)
    assert_equal(month_range[:end].month, 4)
  end

  #    rbcal 10 2013 05 2014  # Oct 2013 - May 2014
  #    rbcal 11/2014 10/2015  # Nov 2014 - Oct 2015
  #    rbcal 09/2014-02/2015  # Sep 2014 - Feb 2015
  def test_month_range_with_years
    month_range = ParamParser.new.parse_command_line_parameters(["10", "2013", "05", "2014"])
    assert_equal(month_range[:start].year, 2013)
    assert_equal(month_range[:start].month, 10)
    assert_equal(month_range[:end].year, 2014)
    assert_equal(month_range[:end].month, 05)

    month_range = ParamParser.new.parse_command_line_parameters(["11/2014", "10/2015"])
    assert_equal(month_range[:start].year, 2014)
    assert_equal(month_range[:start].month, 11)
    assert_equal(month_range[:end].year, 2015)
    assert_equal(month_range[:end].month, 10)

    month_range = ParamParser.new.parse_command_line_parameters(["09/2014-02/2015"])
    assert_equal(month_range[:start].year, 2014)
    assert_equal(month_range[:start].month, 9)
    assert_equal(month_range[:end].year, 2015)
    assert_equal(month_range[:end].month, 2)
  end
end
