require "java"

# Require all the elasticsearch libs
Dir["/home/jls/build/elasticsearch-0.15.0//lib/*.jar"].each do |jar|
  require jar
end

module ElasticSearch; end;

class ElasticSearch::Client
  def initialize
    @node = org.elasticsearch.node.NodeBuilder.nodeBuilder.client(true).node
    @client = @node.client
  end

  def index(index, type, id=nil, &block)
    indexreq = ElasticSearch::IndexRequest.new(@client, index, type, id)
    indexreq.instance_eval(&block)
    return indexreq
  end

end

class ElasticSearch::IndexRequest
  def initialize(client, index, type, id=nil)
    @client = client
    @index = index
    @type = type
    @id = id
    @data = {}

    @indexprep = @client.prepareIndex(index, type, id)
  end

  def execute
    if block_given?
      p "I will be async one day."
      yield
    else
      @indexprep.setSource(@data)
      return @indexprep.execute.actionGet()
    end
  end

  def method_missing(*args)
    key, value = args
    puts "Adding: #{key}: #{value.inspect}"
    @data[key.to_s] = value
  end
end

client = ElasticSearch::Client.new
req = client.index("twitter", "tweet") do
  hello "world"
  foo "bar"
end

p req.execute do
  puts "OK"
end
#p req.execute.actionGet()
