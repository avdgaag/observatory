# Observatory

## Overview

### Description

Observatory is a simple Ruby gem that implements the observer design pattern to facilitate loosely coupled communication between objects in your program. It allows one object to publish an event, and others to respond to that.

Using Observatory you can apply filters to method arguments, respond to events in your program or dynamically inject new functionality.

### What's new?

See HISTORY for a list of changes per version.

## Usage

### Installation

Observatory is distributed as a Ruby gem, so installation is simple:

    $ gem install observatory

Then, you only need to load it in your program using Bundler or a manual require, like so:

    require 'observatory'

### Quick start

For full documentation refer to the inline API docs (which you can generate using the `yard` rake task). A quick overview:

    class Post
      include Observatory::Observable
      
      attr_reader :dispatcher, :title
      
      def initialize(title, dispatcher)
        @title = title
        @dispatcher = dispatcher
      end
      
      def publish
        notify 'post.publish', :title => title
      end
      
      def title
        filter('post.title', @title).return_value
      end
    end
    
    class Logger
      include Observatory::Observer
      
      def initialize(dispatcher)
        @dispatcher = dispatcher
      end
      
      observe 'post.publish'
      def log(event)
        "Post published: #{event[:title]}"
      end
    end
    
    dispatcher = Observatory::Dispatcher.new
    
    dispatcher.connect('post.title') do |event, title|
      "Title: #{title}"
    end
    
    p = Post.new('foo', dispatcher)
    l = Logger.new(dispatcher)
    
    p.publish
    # => Outputs: 'Post published: Title: foo'

## More information

### To Do

* Complete unit tests for mixins.

### Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Commit, do not mess with rakefile, version, or history. (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

### Credits

By Arjan van der Gaag <arjan@arjanvandergaag.nl>. Based on the [Event Dispatcher Symfonoy Component][1].

### License

Observatory is released under the same license as Ruby. See LICENSE for more information.

[1]: http://components.symfony-project.org/event-dispatcher/
