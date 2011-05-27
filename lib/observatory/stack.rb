module Observatory
  # A stack is an Array-like structure that you can add and remove items to, and iterate
  # over in order.
  #
  # Stacks are used to represent a collection of obsevers registered to a signal name
  # in the `Dispatcher`. The stack is responsible for iterating over the registered
  # items in order, so the `Dispatcher` can do stuff with them.
  #
  # Items in this partical stack must be callable objects, like methods, lambdas or procs.
  # When added to a stack, they get assigned a priority. When iterating over the items
  # in a Stack, their priority is used to determine their order.
  #
  # You can manually set an explicit priority, influencing the order of iteration.
  # Priority is a simple integer that is sorted on. By default, the Stack starts counting
  # at `0`, but you can assign an explicit priority of `-1` (or `-984` for that matter) to make
  # sure an item you added to the stack later, will be returned first.
  #
  # @example Iterating over a Stack
  #   stack = Stack.new
  #   stack.push my_proc
  #   stack.each do |o|
  #     puts o # => my_proc
  #   end
  #
  # @example Using priorities
  #   stack = Stack.new
  #   stack.push proc1, 10
  #   stack.push proc2, -10
  #   stack.push proc3
  #   stack.each do |o|
  #     o.inspect
  #   end
  #   # will inspect proc2, proc3, proc1
  #
  # @see Dispatcher
  class Stack
    include Enumerable

    def initialize
      @stack, @default_priority = [], 0
    end

    # The number of items in this stack
    #
    # @return [Fixnum]
    def size
      @stack.size
    end

    # Remove an observer from the stack.
    #
    # @param [#call] observer the callable object that should be removed.
    # @return [#call, nil] the original object or `nil`
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
    # @param [Fixnum] priority is a number indicating return order. A higher number
    #   means lower priority.
    # @return [#call] the original `observer` passed in.
    # @raise `ArgumentError` when not using a `Fixnum` for `priority`
    # @raise `ArgumentError` when not using callable object for `observer`
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
