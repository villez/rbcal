require "minitest/autorun"
require "./rbcal"

# These tests compare the printed output of the RbCal#print_calendar method
# to known good outputs stored in text files. The months are provided
# directly to the RbCal#new constructor, bypassing command-line parameter parsing
# (which is tested separately)


class RbCalTest < Minitest::Test
  def test_single_month
    expected = File.read("test/expected_output/single_month_2013-03.txt")
    out, err = capture_io do
      RbCal.new(Date.new(2013, 03), Date.new(2013, 03)).print_calendar
    end
    assert_equal(expected, out, "Single month printed incorrectly")
  end

  def test_full_year
    expected = File.read("test/expected_output/full_year_2007.txt")
    out, err = capture_io do
      RbCal.new(Date.new(2007, 01), Date.new(2007, 12)).print_calendar
    end
    assert_equal(expected, out, "Full year printed incorrectly")
  end

  def test_month_range_within_year
    expected = File.read("test/expected_output/month_range_2011-02-06.txt")
    out, err = capture_io do
      RbCal.new(Date.new(2011, 02), Date.new(2011, 06)).print_calendar
    end
    assert_equal(expected, out, "Month range within year printed incorrectly")
  end

  def test_month_range_multiple_years
    expected = File.read("test/expected_output/month_range_1995-10-1996-02.txt")
    out, err = capture_io do
      RbCal.new(Date.new(1995, 10), Date.new(1996, 02)).print_calendar
    end
    assert_equal(expected, out, "Month range for multiple years printed incorrectly")
  end
end
