require "jruby-elasticsearch/namespace"
require "jruby-elasticsearch/request"

class ElasticSearch::BulkRequest < ElasticSearch::Request
  # Create a new index request.
  def initialize(client)
    @client = client

    @prep = @client.prepareBulk(index, type, id)
    super
  end

  # Execute this index request.
  # This call is asynchronous.
  #
  # If a block is given, register it for both failure and success.
  def execute(&block)
    use_callback(&block) if block_given
    action = @prep.execute(@handler)
    return action
  end

  # Execute this index request synchronously
  def execute!
    return @prep.execute.actionGet()
  end

  def <<(request)
    @prep.add(request)
  end # def <<
end # def ElasticSearch::BulkRequest
