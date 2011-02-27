require "java"
require "jruby-elasticsearch/namespace"

class ElasticSearch::ActionListener
  include org.elasticsearch.action.ActionListener

  def initialize
    @failure_callbacks = []
    @success_callbacks = []
  end # def initialize

  # Helper for registering callbacks.
  # 'what' should be either :failure or :success
  #
  # You can register multiple callbacks if you wish.
  # Callbacks are invoked in order of addition.
  def on(what, &block)
    case what
    when :failure
      @failure_callbacks << block
    when :success
      @success_callbacks << block
    else
      raise "Unknown event '#{what}' for #{self.class.name}"
    end
    return self
  end # def on
 
  # Conforming to Interface org.elasticsearch.action.ActionListener
  def onFailure(exception)
    if !@failure_callbacks.empty?
      @failure_callbacks.each { |c| c.call(exception) }
    else
      # Default is no failure callbacks
      raise exception
    end
  end # def onFailure

  # Conforming to Interface org.elasticsearch.action.ActionListener
  def onResponse(response)
    if !@success_callbacks.empty?
      @success_callbacks.each { |c| c.call(response) }
    else
      # Default if no success callbacks
      puts "#{self.class.name}#onResponse => #{response.inspect} (#{self})"
    end
  end # def onResponse
end # class ElasticSearch::ActionListener
