require File.join(File.dirname(__FILE__), 'test_helper')

class DispatcherTest < Test::Unit::TestCase
  def setup
    @dispatcher = Dispatcher.new
    @method = method(:example_observer_method)
  end
  
  def example_observer_method
    # does nothing
  end
  
  def test_should_start_with_empty_list_of_observers
    assert_equal({}, @dispatcher.observers)
  end
  
  def test_connecting_an_observer_using_a_method
    @dispatcher.connect('signal', @method)
    assert @dispatcher.observers['signal'].include?(@method)
  end
  
  def test_connecting_an_oversver_using_a_block
    @dispatcher.connect('signal') do
      # does nothing
    end
    assert_equal 1, @dispatcher.observers['signal'].size
  end
  
  def test_connecting_nothing_should_raise_exception
    assert_raise(ArgumentError) { @dispatcher.connect('signal') }
  end
  
  def test_disconnecting_a_new_observer_returns_nil
    assert_nil @dispatcher.disconnect('signal', @method)
  end
  
  def test_disconnecting_an_exisiting_observer_removes_it_from_stack
    @dispatcher.connect('signal', @method)
    assert_equal 1, @dispatcher.observers['signal'].size
    @dispatcher.disconnect('signal', @method)
    assert_equal 0, @dispatcher.observers['signal'].size
  end
  
  def test_notify_calls_all_observers
    flag1 = false
    flag2 = false
    @dispatcher.connect('signal') { flag1 = true }
    @dispatcher.connect('signal') { flag2 = true }
    @dispatcher.notify(Event.new('observable', 'signal'))
    assert flag1
    assert flag2
  end
  
  def test_notify_calls_all_observers_in_order
    output = ''
    @dispatcher.connect('signal') { output << 'a' }
    @dispatcher.connect('signal') { output << 'b' }
    @dispatcher.notify(Event.new('observable', 'signal'))
    assert_equal('ab', output)
  end
  
  def test_using_notify_until_calls_all_observers_until_one_returns_true
    output = ''
    @dispatcher.connect('signal') { output << 'a'; true }
    @dispatcher.connect('signal') { output << 'b' }
    @dispatcher.notify_until(Event.new('observable', 'signal'))
    assert_equal('a', output)
  end
  
  def test_using_filter_uses_original_value_as_default_return_value
    assert_equal 'foo', @dispatcher.filter(Event.new('observable', 'signal'), 'foo').return_value
  end
  
  def test_using_filter_uses_adjusted_value_as_default_return_value
    @dispatcher.connect('signal') { |e,v| v.upcase }
    assert_equal 'FOO', @dispatcher.filter(Event.new('observable', 'signal'), 'foo').return_value
  end
end
