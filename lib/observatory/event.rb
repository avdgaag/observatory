module Observatory
  # An Event is a value object that the observable passes along to the
  # observers. It gives observers easy access to the original observable 
  # and any additional values it may have wanted to pass along
  # (the parameters).
  # 
  # The event object is also returned back to the observable that originally
  # issued it, so it also works as a value object to pass information from
  # the observers to the observable. The event knows whether it has been acted
  # upon, and it can remember a return value that the observable may want to
  # use (and other observers may want to act upon).
  # 
  # The event works just like a regular Ruby Hash, so you can access any
  # parameters just like you would with a hash.
  # 
  # @example Accessing parameters like a Hash
  #   event = Event.new(self, 'post.publish', :title => 'My new post')
  #   event[:title] # => 'My new post'
  # 
  # @note An event is essentially a Hash with some extra properties, so
  #   you can use all the regular Hash and Enumerable methods to your liking.
  class Event < Hash
    
    # The original observable object that issued the event.
    # @return [Object]
    attr_reader :observable
    
    # The name of the signal that the observable triggered. Namespaced with
    # periods.
    # @return [String]
    attr_reader :signal
    
    # The return value for the observable, that observers may modify.
    # @return [Object]
    attr_accessor :return_value

    # Create a new event instance with the given observable and signal. Any
    # parameters are stored, which you can later access like a hash.
    # 
    # @param [Object] observable
    # @param [String, #to_s] signal
    # @param [Hash] parameters is a hash of additional information that
    #   observers may want to use.
    def initialize(observable, signal, parameters = {})
      @observable, @signal = observable, signal.to_s
      merge! parameters
      @processed = false
      super()
    end

    # See if this event has been processed by an observer. Useful when using
    # {Dispatcher#notify_until} to see if there was any observer that actually
    # did something.
    # 
    # @see Dispatcher#notify_until
    # @return [Boolean]
    def processed?
      @processed
    end

    # Mark this event as processed, so the observable knows an observer was
    # active when using {Dispatcher#notify_until}.
    # 
    # @see Dispatcher#notify_until
    # @return [Boolean] true
    def process!
      @processed = true
    end
  end
end
