module Observatory
  class Event < Hash
    attr_reader :subject, :name
    attr_accessor :return_value

    def initialize(subject, name, parameters = {})
      @subject, @name = subject, name
      merge! parameters
      @processed = false
      super()
    end

    def processed?
      @processed
    end

    def process!
      @processed = true
    end
  end
end
