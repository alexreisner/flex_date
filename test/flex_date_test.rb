require 'test/unit'
$:.unshift File.join(File.dirname(__FILE__), '../lib')
require 'flex_date'

class FlexDateTest < Test::Unit::TestCase

  def test_creation
    assert FlexDate.new(1953, 11, 2).is_a?(FlexDate)
    assert FlexDate.new(1953, 11).is_a?(FlexDate)
    assert FlexDate.new(1953).is_a?(FlexDate)
    assert FlexDate.new(nil, 11).is_a?(FlexDate)
    assert FlexDate.new(nil, 11, 2).is_a?(FlexDate)
    assert FlexDate.new(nil, nil, 2).is_a?(FlexDate)
    assert FlexDate.new.is_a?(FlexDate)
  end
  
  def test_accessors
    f = FlexDate.new

    assert !f.complete?
    assert f.year.nil?
    f.year = 1794
    assert_equal 1794, f.year
    
    assert !f.complete?
    assert f.month.nil?
    f.month = 9
    assert_equal 9, f.month

    assert !f.complete?
    assert f.day.nil?
    f.day = 4
    assert_equal 4, f.day

    assert f.complete?
  end
  
  def test_formatting
    f = FlexDate.new
    assert_equal "", f.strftime("%Y")
    f.year = 2087
    assert_equal "2087", f.strftime("%Y")
    assert_equal "2087-", f.strftime("%Y-%m")
    assert_equal "2087", f.to_s("%Y")
    assert_equal "2087", f.to_s(:long)
    f.month = 8
    assert_equal "Aug 2087", f.to_s("%b %e, %Y")
  end
  
  def test_comparison_and_equality
    a = FlexDate.new(2008,6,4)
    b = FlexDate.new(2004,9,30)
    assert_equal 0, a <=> a
    assert a == a
    assert a != b
    assert_equal 1, a <=> b
    c = FlexDate.new(2004)
    d = FlexDate.new(1980,8,3)
    e = FlexDate.new(1945,6)
    assert_equal [e,d,c,b,a], [b,e,a,d,c].sort
  end
end
