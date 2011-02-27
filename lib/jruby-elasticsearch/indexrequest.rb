require "jruby-elasticsearch/namespace"
require "jruby-elasticsearch/request"

class ElasticSearch::IndexRequest < ElasticSearch::Request
  # Create a new index request.
  def initialize(client, index, type, id=nil, data={})
    @client = client
    @index = index
    @type = type
    @id = id
    @data = data

    @prep = @client.prepareIndex(index, type, id)
    super()
  end

  # Execute this index request.
  # This call is asynchronous.
  #
  # If a block is given, register it for both failure and success.
  def execute(&block)
    @prep.setSource(@data)
    use_callback(&block) if block_given?

    action = @prep.execute(@handler)
    return action
  end

  # Execute this index request synchronously
  def execute!
    @prep.setSource(@data)
    return @prep.execute.actionGet()
  end

  # DSL helper.
  # TODO(sissel): Move this away to a DSL module.
  def method_missing(*args)
    key, value = args
    puts "Adding: #{key}: #{value.inspect}"
    @data[key.to_s] = value
  end
end
