require "test_helper"
require "vscal/param_parser"

# These tests verify that the command-line parser identifies the parameter combinations
# correctly. The actual calendar printing functionality is not included in these tests,
# but tested separately.
#
# The supported formats are:
#    vscal                  # current month
#    vscal +N               # current month and N next months
#    vscal 2015             # full year, Jan-Dec 2015
#    vscal 7-10             # July-October for current year
#    vscal 10-05            # Oct this year - May next year
#    vscal 05 2014          # May 2014
#    vscal 03/2015          # March 2015
#    vscal 10-12 2013       # Oct-Dec 2013
#    vscal 03-04/2016       # Mar-Apr 2016
#    vscal 10 2013 05 2014  # Oct 2013 - May 2014
#    vscal 11/2014 10/2015  # Nov 2014 - Oct 2015
#    vscal 09/2014-02/2015  # Sep 2014 - Feb 2015
#
# The ParamParser#parse_command_line_parameters method takes an ARGV-like array
# which is essentially the command line parameter string split on whitespace


class ParamParserTest < Minitest::Test
  def setup
    @this_year = Date.today.year
    @this_month = Date.today.month
  end

  # no parameters  => print current month
  def test_default
    month_range = VsCal::ParamParser.new.parse_command_line_parameters([])

    assert_equal(@this_year, month_range[:start].year)
    assert_equal(@this_month, month_range[:start].month)
    assert_equal(@this_year, month_range[:end].year)
    assert_equal(@this_month, month_range[:end].month)
  end

  # vscal +N  => current month and N next months
  def test_plus_month
    plus = 7
    month_range = VsCal::ParamParser.new.parse_command_line_parameters(["+#{plus}"])

    # accounting for the fact that the "plus N months" logic can
    # result in wrapping to the next year
    if ((@this_month + plus) > 12)
      plus_year = @this_year + 1
      plus_month = (@this_month + plus) % 12
    else
      plus_year = @this_year
      plus_month = @this_month + plus
    end

    assert_equal(@this_year, month_range[:start].year)
    assert_equal(@this_month, month_range[:start].month)
    assert_equal(plus_year, month_range[:end].year)
    assert_equal(plus_month, month_range[:end].month)

  end

  # vscal 2015  => full year, Jan-Dec 2015
  def test_full_year
    month_range = VsCal::ParamParser.new.parse_command_line_parameters(["2015"])

    assert_equal(2015, month_range[:start].year)
    assert_equal(1, month_range[:start].month)
    assert_equal(2015, month_range[:end].year)
    assert_equal(12, month_range[:end].month)
  end

  # vscal 7-10  => July-October for current year
  def test_month_range_current_year
    month_range = VsCal::ParamParser.new.parse_command_line_parameters(["7-10"])

    assert_equal(@this_year, month_range[:start].year)
    assert_equal(7, month_range[:start].month)
    assert_equal(@this_year, month_range[:end].year)
    assert_equal(10, month_range[:end].month)
  end

  # vscal 10-05  => Oct this year - May next year
  def test_month_range_cross_year
    month_range = VsCal::ParamParser.new.parse_command_line_parameters(["10-5"])

    assert_equal(@this_year, month_range[:start].year)
    assert_equal(10, month_range[:start].month)
    assert_equal(@this_year + 1, month_range[:end].year)
    assert_equal(5, month_range[:end].month)
  end

  # vscal 05 2014  => May 2014
  def test_single_month_with_year_space
    month_range = VsCal::ParamParser.new.parse_command_line_parameters(["05", "2014"])

    assert_equal(2014, month_range[:start].year)
    assert_equal(5, month_range[:start].month)
    assert_equal(2014, month_range[:end].year)
    assert_equal(5, month_range[:end].month)
  end

  # vscal 03/2015  => March 2015
  def test_single_month_with_year_slash
    month_range = VsCal::ParamParser.new.parse_command_line_parameters(["03/2015"])

    assert_equal(2015, month_range[:start].year)
    assert_equal(3, month_range[:start].month)
    assert_equal(2015, month_range[:end].year)
    assert_equal(3, month_range[:end].month)
  end


  # vscal 10-12 2013  => Oct-Dec 2013
  def test_month_range_with_year_space
    month_range = VsCal::ParamParser.new.parse_command_line_parameters(["10-12", "2013"])

    assert_equal(2013, month_range[:start].year)
    assert_equal(10, month_range[:start].month)
    assert_equal(2013, month_range[:end].year)
    assert_equal(12, month_range[:end].month)
  end

  # vscal 03-04/2016  => Mar-Apr 2016
  def test_month_range_with_year_slash
    month_range = VsCal::ParamParser.new.parse_command_line_parameters(["03-04/2016"])

    assert_equal(2016, month_range[:start].year)
    assert_equal(3, month_range[:start].month)
    assert_equal(2016, month_range[:end].year)
    assert_equal(4, month_range[:end].month)
  end

  # vscal 10 2013 05 2014  => Oct 2013 - May 2014
  def test_month_range_with_years_spaces
    month_range = VsCal::ParamParser.new.parse_command_line_parameters(["10", "2013", "05", "2014"])

    assert_equal(2013, month_range[:start].year)
    assert_equal(10, month_range[:start].month)
    assert_equal(2014, month_range[:end].year)
    assert_equal(5, month_range[:end].month)
  end

  # vscal 11/2014 10/2015  => Nov 2014 - Oct 2015
  def test_month_range_with_years_slash_space
    month_range = VsCal::ParamParser.new.parse_command_line_parameters(["11/2014", "10/2015"])

    assert_equal(2014, month_range[:start].year)
    assert_equal(11, month_range[:start].month)
    assert_equal(2015, month_range[:end].year)
    assert_equal(10, month_range[:end].month)
  end

  # vscal 09/2014-02/2015  => Sep 2014 - Feb 2015
  def test_month_range_with_years_slash_dash
    month_range = VsCal::ParamParser.new.parse_command_line_parameters(["09/2014-02/2015"])

    assert_equal(2014, month_range[:start].year)
    assert_equal(9, month_range[:start].month)
    assert_equal(2015, month_range[:end].year)
    assert_equal(2, month_range[:end].month)
  end
end
