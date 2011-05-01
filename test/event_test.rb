require File.join(File.dirname(__FILE__), 'test_helper')

class EventTest < Test::Unit::TestCase
  def setup
    @event = Event.new('observable', 'signal', :foo => 'bar')
  end
  
  def test_works_like_a_hash
    assert_equal('bar', @event[:foo])
    assert_kind_of(Hash, @event)
  end
  
  def test_should_be_processed_by_default
    assert !@event.processed?
  end
  
  def test_should_be_marked_processed
    @event.process!
    assert @event.processed?
  end
  
  def test_require_observable_and_signal
    assert_raise(ArgumentError) { Event.new }
    assert_raise(ArgumentError) { Event.new('foo') }
  end
  
  def test_do_not_require_parameters
    assert_nothing_raised { Event.new('foo', 'bar') }
  end
  
  def test_use_signal_as_string
    event = Event.new('foo', 123)
    assert_equal('123', event.signal)
  end
  
  def test_has_a_return_value_attribute
    @event.return_value = :foo
    assert_equal(:foo, @event.return_value)
  end
end
