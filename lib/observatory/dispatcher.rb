module Observatory
  class Dispatcher
    attr_reader :listeners

    def initialize
      @listeners = {}
    end

    def connect(name, listener = nil, &block)
      if listener.nil?
        if block_given?
          listener = block
        else
          raise ArgumentError, 'Use a block, method or proc to specify a listener'
        end
      end
      listeners[name] ||= []
      listeners[name] << listener
    end

    def disconnect(name, listener)
      return nil unless listeners.key?(name)
      listeners[name].delete(listener)
    end

    def notify(event)
      each(event.name) do |listener|
        listener.call(event)
      end
      event
    end

    def notify_until(event)
      each(event.name) do |listener|
        event.process! and break if listener.call(event)
      end
    end

    def filter(event, value)
      each(event.name) do |listener|
        value = listener.call(event, value)
      end
      event.return_value = value
      event
    end

  private

    def each(name, &block)
      (listeners[name] || []).each(&block)
    end
  end
end
