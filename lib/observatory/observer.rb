module Observatory
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
