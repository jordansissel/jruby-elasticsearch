require "java"
require "jruby-elasticsearch/namespace"
require "jruby-elasticsearch/indexrequest"

class ElasticSearch::Client
  def initialize
    @node = org.elasticsearch.node.NodeBuilder.nodeBuilder.client(true).node
    @client = @node.client
  end # def initialize

  # Index a new document
  #
  # args:
  #   index: the index name
  #   type: the type name
  #   id: (optional) the id of the document
  #   data: (optional) the data for this document
  #   &block: (optional) optional block for using the DSL to add data
  #
  # Returns an ElasticSearch::IndexRequest instance.
  #
  # Example w/ DSL:
  #
  #     request = client.index("foo", "logs") do
  #       filename "/var/log/message"
  #       mesage "hello world"
  #       timestamp 123456
  #     end
  #
  #     request.execute!
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
  end # def index

  def cluster
    return @client.admin.cluster
  end

  def node
    return @client.admin.cluster
  end
end # class ElasticSearch::Client

