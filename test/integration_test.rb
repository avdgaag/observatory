require File.join(File.dirname(__FILE__), 'test_helper')
require 'stringio'

class Post
  include Observatory::Observable
  
  attr_reader :title
  
  def initialize(title, dispatcher)
    @title, @dispatcher = title, dispatcher
  end
  
  def publish
    notify('post.publish', :title => title)
  end
  
  def title
    filter('post.title', @title).return_value
  end
  
  def save
    event = notify_until('post.save', :title => title)
    raise Exception, 'Saving is not implemented!' unless event.processed?
  end
end

class Spy
  include Observatory::Observer
  
  attr_reader :buffer
  
  def initialize(dispatcher, buffer)
    @dispatcher, @buffer = dispatcher, buffer
  end
  
  observe 'post.publish'
  def log_publication(event)
    buffer.puts "Post titled #{event[:title]} was published"
  end
  
  observe 'post.title'
  def title_filter(event, value)
    value.upcase
  end
  
  observe 'post.save'
  def save_post_to_output(event)
    buffer.puts "Saving post titled #{event[:title]}"
    true
  end
end

class IntegrationTest < Test::Unit::TestCase
  def setup
    @buffer = StringIO.new
    @dispatcher = Observatory::Dispatcher.new
    @post = Post.new('My new post', @dispatcher)
    @spy = Spy.new(@dispatcher, @buffer)
  end
  
  def test_notify
    @dispatcher.disconnect('post.title', @spy.method(:title_filter))
    @post.publish
    assert_equal("Post titled My new post was published\n", @buffer.string)
  end
  
  def test_filter
    assert_equal("MY NEW POST", @post.title)
  end
  
  def test_notify_until
    @dispatcher.disconnect('post.title', @spy.method(:title_filter))
    assert_nothing_raised(Exception) { @post.save }
    assert_equal("Saving post titled My new post\n", @buffer.string)
    @dispatcher.disconnect('post.save', @spy.method(:save_post_to_output))
    assert_raise(Exception) { @post.save }
  end
end
