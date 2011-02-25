require "java"
require "elasticsearch/namespace"
require "elasticsearch/indexrequest"

class ElasticSearch::Client
  def initialize
    @node = org.elasticsearch.node.NodeBuilder.nodeBuilder.client(true).node
    @client = @node.client
  end

  def index(index, type, id=nil, data={}, &block)
    # Permit 'id' being omitted entirely.
    # Thus a call call: index("foo", "bar", somehash) is valid.
    if id.is_a?(Hash)
      data = id
      id = nil
    end

    indexreq = ElasticSearch::IndexRequest.new(@client, index, type, id, data)
    if block_given?
      indexreq.instance_eval(&block)
    end
    return indexreq
  end
end

