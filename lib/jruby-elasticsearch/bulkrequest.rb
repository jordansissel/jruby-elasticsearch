require "jruby-elasticsearch/namespace"
require "jruby-elasticsearch/request"

class ElasticSearch::BulkRequest < ElasticSearch::Request
  # Create a new index request.
  public
  def initialize(client)
    @client = client
    @prep = @client.prepareBulk()
    super()
  end # def initialize

  # Execute this index request.
  # This call is asynchronous.
  #
  # If a block is given, register it for both failure and success.
  def execute(&block)
    use_callback(&block) if block_given?
    action = @prep.execute(@handler)
    return action
  end # def execute

  # Execute this index request synchronously
  public
  def execute!
    return @prep.execute.actionGet()
  end # def execute!

  # Index a document.
  public
  def index(index, type, id=nil, data={})
    req = org.elasticsearch.action.index.IndexRequest.new(index)
    req.type(type) if type
    req.id(id.to_s) if id
    req.source(data)
    @prep.add(req)
  end

  public
  def <<(request)
    @prep.add(request)
  end # def <<
end # def ElasticSearch::BulkRequest
