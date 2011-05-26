module Observatory
  # Manages a list of callable objects with priorities, so when iterating over
  # a stack, the elements are always returned in order.
  class Stack
    include Enumerable

    def initialize
      @stack, @default_priority = [], 0
    end

    # Get the size of the internal stack
    #
    # @return [Fixnum]
    def size
      @stack.size
    end

    # Remove an observer from the stack.
    #
    # @param [#call] the observer callable object that should be removed.
    # @return [#call] the original object or nil
    def delete(observer)
      old_size = @stack.size
      @stack.delete_if do |o|
        o[:observer] == observer
      end
      old_size == @stack.size ? nil : observer
    end

    # Add an element to the stack with an optional priority.
    #
    # @param [#call] observer is the callable object that acts as observer.
    # @param [Fixnum] priority is a number indicating priorty. A higher number
    #   means lower priority.
    # @return [#call] the original observer passed in.
    # @raise ArgumentError when not using an Fixnum for priority
    # @raise ArgumentError when not using callable object for observer
    def push(observer, priority = nil)
      raise ArgumentError, 'Observer is not callable' unless observer.respond_to?(:call)
      raise ArgumentError, 'Priority must be Fixnum' unless priority.nil? || priority.is_a?(Fixnum)

      @stack.push({ :observer => observer, :priority => (priority || default_priority) })
      sort_by_priority
      observer
    end
    alias_method :<<, :push

    # Iterator for our Enumerable mixin.
    #
    # This will yield every element in the stack, without its priority -- just the
    # plain observer object.
    #
    # @yield [#call] observer
    # @return [Stack] itself
    def each
      @stack.each { |e| yield e[:observer] }
      self
    end

  private

    # Increment the internal default priority counter and return its new value.
    def default_priority
      @default_priority = @default_priority.next
    end

    # Re-sort the internal stack of observers by their priority attributes.
    # This changes the `@stack` in place.
    def sort_by_priority
      @stack.sort! { |a, b| a[:priority] <=> b[:priority] }
    end
  end
end
