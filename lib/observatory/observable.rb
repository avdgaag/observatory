module Observatory
  # An observable object can publish events to registered observers. This
  # module provides some simple helper methods as syntactic sugar.
  # 
  # Using these shortcut methods will default the observable object of the
  # events raised to `self`, so the method signatures are the same as in
  # {Dispatcher} but without the first one, the observable object.
  # 
  # @note Including this module will create a read-only attribute `dispatcher`
  #   but not set it. You need to populate it yourself.
  # 
  # @example Manually triggering events in your code
  #   class Post
  #     attr_reader :dispatcher
  #   
  #     def initialize(dispatcher)
  #       @dispatcher = dispatcher
  #     end
  #   
  #     def publish
  #       event = Observatory::Event.new(self, 'post.publish')
  #       dispatcher.notify(event)
  #     end
  #   end
  # 
  # @example Using the Observable shortcut methods
  #   class Post
  #     include Observatory::Observable
  #   
  #     def publish
  #       notify('post.publish') # => instance of Event
  #     end
  #   end
  # 
  # @see Observer
  module Observable
    def self.included(base)
      base.send(:attr_reader, :dispatcher)
    end

    # @see Dispatcher#notify
    def notify(*args)
      Observatory::Event.new(self, *args).tap do |e|
        dispatcher.notify(e)
      end
    end

    # @see Dispatcher#filter
    def filter(*args)
      value = args.pop
      Observatory::Event.new(self, *args).tap do |e|
        dispatcher.filter(e, value)
      end
    end
    
    # @see Dispatcher#notify_until
    def notify_until(*args)
      Observatory::Event.new(self, *args).tap do |e|
        dispatcher.notify_until(e)
      end
    end
  end
end
