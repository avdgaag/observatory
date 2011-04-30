module Observatory
  module Observable
    def self.included(base)
      base.send(:attr_reader, :dispatcher)
    end

    def notify(*args)
      Observatory::Event.new(self, *args).tap do |e|
        dispatcher.notify(e)
      end
    end

    def filter(*args)
      value = args.pop
      Observatory::Event.new(self, *args).tap do |e|
        dispatcher.filter(e, value)
      end
    end
    
    def notify_until(*args)
      Observatory::Event.new(self, *args).tap do |e|
        dispatcher.notify_until(e)
      end
    end
  end
end
