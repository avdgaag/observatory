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
  # An observer may be anything that is callable, but will usually
  # be a method, block or Proc object. You may optionally specify an
  # explicit priority for an observer, to make sure it gets called before
  # or after other observers.
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
    # Optionally, you could pass in an options hash as the last argument, that
    # can specify an explicit priority. When omitted, an internal counter starting
    # from 1 will be used. To make sure your observer is called last, specify
    # a high, **positive** number. To make sure your observer is called first, specify
    # a high, **negative** number.
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
    # @example Determining observer call order using priority
    #   dispatcher.connect('pulp', :priority => 10) do
    #     puts "I dare you!"
    #   end
    #   dispatcher.connect('pulp', :priority => -10) do
    #     puts "I double-dare you!"
    #   end
    #   # output when "pulp" is triggered:
    #   "I double-dare you!"
    #   "I dare you!"
    #
    # @overload connect(signal, observer, options = {})
    #   @param [String] signal is the name used by the observable to trigger
    #     observers
    #   @param [#call] observer is the Proc or method that will react to
    #     an event issued by an observable.
    #   @param [Hash] options is an optional Hash of additional options.
    #   @option options [Fixnum] :priority is the priority of this observer
    #     in the stack of all observers for this signal. A higher number means
    #     lower priority. Negative numbers are allowed.
    # @overload connect(signal, options = {}, &block)
    #   @param [String] signal is the name used by the observable to trigger
    #     observers
    #   @param [Hash] options is an optional Hash of additional options.
    #   @option options [Fixnum] :priority is the priority of this observer
    #     in the stack of all observers for this signal. A higher number means
    #     lower priority. Negative numbers are allowed.
    # @return [#call] the added observer
    def connect(signal, *args, &block)
      # ugly argument parsing.
      # Make sure that there is either a block given, or that the second argument is
      # something callable. If there is a block given, the second argument, if given,
      # must be a Hash which defaults to an empty Hash. If there is no block given,
      # the third optional argument must be Hash.
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

      # Initialize the list of observers for this signal and add this observer
      observers[signal] ||= Stack.new
      observers[signal].push(observer, options[:priority])
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
      (observers[signal] || []).each do |observer|
        yield observer
      end
    end
  end
end

