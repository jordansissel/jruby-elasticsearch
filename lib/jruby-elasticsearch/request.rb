require "jruby-elasticsearch/namespace"
require "jruby-elasticsearch/actionlistener"

class ElasticSearch::Request
  # Create a new index request.
  def initialize()
    @handler = ElasticSearch::ActionListener.new
  end

  # See ElasticSearch::ActionListener#on
  def on(event, &block)
    #puts "Event[#{event}] => #{block} (#{@handler})"
    @handler.on(event, &block)
    return self
  end

  # Execute this index request.
  # This call is asynchronous.
  #
  # If a block is given, register it for both failure and success.
  def use_callback(&block)
    if block_given?
      on(:failure, &block)
      on(:success, &block)
    end
  end
end
