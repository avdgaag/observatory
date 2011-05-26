---
layout: default
title: Observatory
tagline: a simple observer pattern implementation
nav:
  - url: http://avdgaag.github.com/observatory
    label: Homepage
  - url: http://github.com/avdgaag/observatory/issues
    label: Issues
  - url: http://github.com/avdgaag/observatory
    label: Source
  - url: doc
    label: Docs
---
Observatory is a simple Ruby gem that implements the observer design pattern to facilitate loosely coupled communication between objects in your program. It allows one object to publish an event, and others to respond to that.
{: .leader }

Using Observatory you can apply filters to method arguments, respond to events in your program or dynamically inject new functionality.

## Installation

Observatory is distributed as a Ruby gem, so installation is simple:

{% highlight sh %}
$ gem install observatory
{% endhighlight %}

Then, you only need to load it in your program using Bundler or a manual require, like so:

{% highlight ruby %}
require 'observatory'
{% endhighlight %}

## Quick start

For full documentation refer to the [inline API docs][2] (which you can generate using the `yard` Rake task). A quick overview:

{% highlight ruby %}
class Post
  include Observatory::Observable

  attr_reader :dispatcher, :title

  def initialize(title, dispatcher)
    @title = title
    @dispatcher = dispatcher
  end

  def publish
    notify 'post.publish', :title =&gt; title
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
{% endhighlight %}

## Documentation

This project is still under development, so there's not a lot of documentation yet -- apart from the [API docs with inline docs][2].

## Credits

* **Author**: Arjan van der Gaag (<arjan@arjanvandergaag.nl>)
* **License**: MIT License (same as Ruby)

Based on the [Event Dispatcher Symfonoy Component][1].

[1]: http://components.symfony-project.org/event-dispatcher/
[2]: doc/index.html
