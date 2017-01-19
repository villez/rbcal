require "minitest/autorun"
require "vscal"

# These tests compare the printed output of the VsCal#print_calendar method
# to known good outputs stored in text files. The months are provided
# directly to the VsCal#new constructor, bypassing command-line parameter parsing
# (which is tested separately)


class VsCalTest < Minitest::Test
  def test_single_month
    expected = File.read("test/expected_output/single_month_2011-03.txt")
    assert_output(expected) do
      VsCal.new(Date.new(2011, 03), Date.new(2011, 03), false).print_calendar
    end
  end

  def test_full_year
    expected = File.read("test/expected_output/full_year_2007.txt")
    assert_output(expected) do
      VsCal.new(Date.new(2007, 01), Date.new(2007, 12), false).print_calendar
    end
  end

  def test_month_range_within_year
    expected = File.read("test/expected_output/month_range_2011-02-06.txt")
    assert_output(expected) do
      VsCal.new(Date.new(2011, 02), Date.new(2011, 06), false).print_calendar
    end
  end

  def test_month_range_multiple_years
    expected = File.read("test/expected_output/month_range_1995-10-1996-02.txt")
    assert_output(expected) do
      VsCal.new(Date.new(1995, 10), Date.new(1996, 02), false).print_calendar
    end
  end
end
