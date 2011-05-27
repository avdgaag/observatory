require File.join(File.dirname(__FILE__), 'test_helper')

class StackTest < Test::Unit::TestCase
  def setup
    @observer = Proc.new {}
    @observer2 = Proc.new {}
    @stack = Stack.new
  end

  def test_get_the_size
    @stack.push(@observer)
    assert_equal 1, @stack.size
  end

  def test_start_empty
    assert_equal 0, @stack.size
  end

  def test_is_enumerable
    @stack.push @observer
    @stack.each do |o|
      assert_equal @observer, o
    end
  end

  def test_remove_item
    @stack.push @observer
    assert_equal 1, @stack.size
    @stack.delete @observer
    assert_equal 0, @stack.size
  end

  def test_return_nil_when_no_item_to_remove
    assert_nil @stack.delete(@observer)
  end

  def test_return_item_itself_after_removing
    @stack.push @observer
    assert_equal @observer, @stack.delete(@observer)
  end

  def test_add_item_to_stack
    assert_equal @observer, @stack.push(@observer)
    assert_equal 1, @stack.size
  end

  def test_use_default_priority_for_new_item
    @stack.push @observer
    @stack.push @observer2
    @stack.each_with_index do |o, i|
      assert_equal @observer,  o if i == 0
      assert_equal @observer2, o if i == 1
    end
  end

  def test_set_explicit_priority_for_new_item
    assert_nothing_raised do
      @stack.push @observer, 10
    end
    assert_equal 1, @stack.size
  end

  def test_sort_after_adding_item
    @stack.push @observer, 1
    @stack.push @observer2, -1
    @stack.each_with_index do |o, i|
      assert_equal @observer2, o if i == 0
      assert_equal @observer,  o if i == 1
    end
  end

  def test_require_callable_item
    assert_raise ArgumentError do
      @stack.push 'foo'
    end
  end

  def test_require_fixnum_priority
    assert_raise ArgumentError do
      @stack.push @observer, 'foo'
    end
  end
end

