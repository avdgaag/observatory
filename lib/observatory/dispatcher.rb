module Observatory
  # The Dispatcher is the central repository of all registered observers, and
  # is used by observables to send out signals to these observers.
  # 
  # A dispatcher is not a singleton object, which means you may very well have
  # several dispatcher objects in your program, keeping track of different
  # stacks of observers and observables. Note that this requires you to pass
  # your dispatcher object around using dependency injection.
  # 
  # ## For observables
  # 
  # The stack of observers for any given signal is kept in {#observers}. When
  # using {#notify}, {#notify_until} or {#filter} all observers in the stack
  # will be called.
  # 
  # ### Notification methods
  # 
  # Observable objects may use the following methods to trigger their
  # observers:
  # 
  # * {#notify} to call all observers.
  # * {#notify_until} to call observers until one stops the chain.
  # * {#filter} to let all observers alter a given value.
  # 
  # ## For observers
  # 
  # An object that observes another object is an observer, and it can
  # register itself with the {Dispatcher} to listen to a signal that
  # observable objects may issue.
  # 
  # @example Using {#connect} to register a new observer
  #   class Logger
  #     def log(event)
  #       puts "Post published by #{event.observable}"
  #     end
  #   end
  #   logger = Logger.new
  #   dispatcher.connect('post.publish', logger.method(:log))
  # 
  # @example Using {#disconnect} to unregister an observer
  #   dispatcher.disconnect('post.publish', logger.method(:log))
  # 
  # @example Using {#notify} to let other objects know something has happened
  #   class Post
  #     include Observable
  #     attr_reader :title
  #     def publish
  #       notify 'post.publish', :title => title
  #       # do publication stuff here
  #     end
  #   end
  # 
  # @example Using {#notify_until} to delegate saving a record to another object
  #   class Post
  #     def save
  #       notify_until 'post.save', :title => title
  #     end
  #   end
  # 
  # @example Using {#filter} to let observers modify the output of the title attribute
  #   class Post
  #     def title
  #       filter('post.title', @title).return_value
  #     end
  #   end
  class Dispatcher
    # A list of all registered observers grouped by signal.
    # @return [Hash]
    attr_reader :observers

    def initialize
      @observers = {}
    end
    
    # Register a observer for a given signal.
    # 
    # Instead of adding a method or Proc object to the stack, you could
    # also use a block. Either the observer argument or the block is required.
    # 
    # @example Using a block as an observer
    #   dispatcher.connect('post.publish') do |event|
    #     puts "Post was published"
    #   end
    # 
    # @example Using a method as an observer
    #   class Reporter
    #     def log(event)
    #       puts "Post published"
    #     end
    #   end
    #   dispatcher.connect('post.publish', Reporter.new.method(:log))
    # 
    # @param [String] signal is the name used by the observable to trigger
    #   observers
    # @param [#call] observer is the Proc or method that will react to
    #   an event issued by an observable.
    # @return [#call] the added observer
    def connect(signal, *args, &block)
      if block_given?
        observer = block
        if args.size == 1 && args.first.is_a?(Hash)
          options = args.first
        elsif args.size == 0
          options = {}
        else
          raise ArgumentError, 'When given a block, #connect only expects a signal and options hash as arguments'
        end
      else
        observer = args.shift
        raise ArgumentError, 'Use a block, method or proc to specify an observer' unless observer.respond_to?(:call)
        if args.any?
          options = args.shift
          raise ArgumentError, '#connect only expects a signal, method and options hash as arguments' unless options.is_a?(Hash) || args.any?
        else
          options = {}
        end
      end
      observers[signal] ||= []
      observers[signal] << observer
    end

    # Removes an observer from a signal stack, so it no longer gets triggered.
    # 
    # @param [String] signal is the name of the stack to remove the observer
    #   from.
    # @param [#call] observer is the original observer to remove.
    # @return [#call, nil] the removed observer or nil if it could not be found
    def disconnect(signal, observer)
      return nil unless observers.key?(signal)
      observers[signal].delete(observer)
    end

    # Send out a signal to all registered observers using a new {Event}
    # instance. The {Event#signal} will be used to determine the stack of
    # {#observers} to use.
    # 
    # Using {#notify} allows observers to take action at a given time during
    # program execution, such as logging important events.
    # 
    # @param [Event]
    # @return [Event]
    def notify(event)
      each(event.signal) do |observer|
        observer.call(event)
      end
      event
    end

    # Same as {#notify}, but halt execution as soon as an observer has
    # indicated it has handled the event by returning a non-falsy value.
    # 
    # An event that was acted upon by an observer will be marked as processed.
    # 
    # @param [Event]
    # @see Event#process!
    # @return [Event]
    def notify_until(event)
      each(event.signal) do |observer|
        event.process! and break if observer.call(event)
      end
      event
    end

    # Let all registered observers modify a given value. The observable can
    # then use the {Event#return_value} to get the filtered result back.
    # 
    # You could use {#filter} to let observers modify arguments to a method
    # before continuing to work on them (just an example).
    # 
    # @param [Event]
    # @param [Object] value
    # @return [Event]
    def filter(event, value)
      each(event.signal) do |observer|
        value = observer.call(event, value)
      end
      event.return_value = value
      event
    end

  private

    def each(signal, &block)
      (observers[signal] || []).each(&block)
    end
  end
end
