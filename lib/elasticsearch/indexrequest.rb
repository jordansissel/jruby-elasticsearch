require "elasticsearch/namespace"
require "elasticsearch/actionlistener"

class ElasticSearch::IndexRequest
  def initialize(client, index, type, id=nil, data={})
    @client = client
    @index = index
    @type = type
    @id = id
    @data = data
    @indexprep = @client.prepareIndex(index, type, id)
    @handler = ElasticSearch::ActionListener.new
  end

  def on(*args, &block)
    return @handler.on(*args, &block)
  end

  def execute
    @indexprep.setSource(@data)
    action = @indexprep.execute(@handler)
    return action
  end

  def execute!
    @indexprep.setSource(@data)
    return @indexprep.execute.actionGet()
  end

  def method_missing(*args)
    key, value = args
    puts "Adding: #{key}: #{value.inspect}"
    @data[key.to_s] = value
  end
end
