require "minitest/autorun"
require "./rbcal"

class RbCalTest < Minitest::Test
  def test_single_month
    expected = File.read("test/expected_output/single_month_2013-03.txt")
    out, err = capture_io do
      RbCal.new(DateTime.new(2013, 03), DateTime.new(2013, 03)).print_calendar
    end
    assert_equal(expected, out)
  end

  def test_month_range_within_year
    expected = File.read("test/expected_output/month_range_2011-02-06.txt")
    out, err = capture_io do
      RbCal.new(DateTime.new(2011, 02), DateTime.new(2011, 06)).print_calendar
    end
    assert_equal(expected, out)
  end
end
