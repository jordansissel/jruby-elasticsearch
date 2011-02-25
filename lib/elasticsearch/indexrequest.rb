require "elasticsearch/namespace"
require "elasticsearch/actionlistener"

class ElasticSearch::IndexRequest
  # Create a new index request.
  def initialize(client, index, type, id=nil, data={})
    @client = client
    @index = index
    @type = type
    @id = id
    @data = data
    @indexprep = @client.prepareIndex(index, type, id)
    @handler = ElasticSearch::ActionListener.new
  end

  # See ElasticSearch::ActionListener#on
  def on(event, &block)
    return @handler.on(*args, &block)
  end

  # Execute this index request.
  # This call is asynchronous.
  #
  # If a block is given, register it for both failure and success.
  def execute(&block)
    @indexprep.setSource(@data)
    if block_given?
      on(:failure, &block)
      on(:success, &block)
    end

    action = @indexprep.execute(@handler)
    return action
  end

  # Execute this index request synchronously
  def execute!
    @indexprep.setSource(@data)
    return @indexprep.execute.actionGet()
  end

  # DSL helper.
  # TODO(sissel): Move this away to a DSL module.
  def method_missing(*args)
    key, value = args
    puts "Adding: #{key}: #{value.inspect}"
    @data[key.to_s] = value
  end
end
