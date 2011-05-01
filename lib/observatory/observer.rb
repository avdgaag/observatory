module Observatory
  # @note Including the Observer module in your object will override your
  #   initializer.
  # 
  # The Observer module enhances your classes with some simple syntactic sugar
  # to register methods as observers. You may very well register your
  # methods manually, but these methods may increase your code readability.
  # 
  # This module will override your `initialize` method to automatically
  # register all observer methods with the dispatcher. In order to do so,
  # it will alias your own `initialize` method and create a new one that
  # both calls the old initializer and registers observers. This does mean
  # that your initializer needs to set up a dispatcher object, probably
  # via constructor dependency injection.
  # 
  # The main benefit of using this module in your classes is you get the
  # class macro `observe` which will set up the next method that is declared
  # in the class as an observer for the given signal name.
  # 
  # @example Registering a method as an observer for a signal
  #   class Logger
  #     include Observatory::Observer
  # 
  #     def initialize(dispatcher)
  #       @dispatcher = dispatcher
  #     end
  # 
  #     observe 'post.publish'
  #     def log(event)
  #       puts "Event #{event.signal} happened at #{Time.now}"
  #     end
  #   end
  # 
  # @todo allow registering a single method to mulitple signals, or even
  #   matching by regular expression...?
  # @todo this is pretty magicky. Might need to refactor to make things more
  #   explicit and obvious.
  module Observer
    def self.included(base)
      base.extend ClassMethods
      base.overwrite_initialize
      base.class_eval do
        attr_reader :dispatcher
      end

      base.instance_eval do
        def method_added(name)
          if name == :initialize
            overwrite_initialize
          else
            if @observer_next_event_name_to_observe
              @observers_to_set_up ||= {}
              @observers_to_set_up[@observer_next_event_name_to_observe] ||= []
              @observers_to_set_up[@observer_next_event_name_to_observe] << name
              @observer_next_event_name_to_observe = nil
            end
          end
        end
      end
    end
    
    module ClassMethods
      def overwrite_initialize
        class_eval do
          unless method_defined?(:initialize_and_setup_observers)
            define_method(:initialize_and_setup_observers) do |*args|
              initialize_without_observer *args
              self.class.observers_to_set_up.each_pair do |name, methods|
                methods.each do |m|
                  @dispatcher.connect(name, method(m))
                end
              end
            end
          end
          if instance_method(:initialize) != instance_method(:initialize_and_setup_observers)
            alias_method :initialize_without_observer, :initialize
            alias_method :initialize, :initialize_and_setup_observers
          end
        end
      end

      def observers_to_set_up
        @observers_to_set_up ||= {}
      end

      def observe(event_name)
        @observer_next_event_name_to_observe = event_name
      end
    end
  end
end
