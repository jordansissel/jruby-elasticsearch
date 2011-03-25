require "jruby-elasticsearch/namespace"
require "jruby-elasticsearch/request"

class ElasticSearch::SearchRequest < ElasticSearch::Request
  # Create a new index request.
  def initialize(client)
    @client = client
    @prep = @client.prepareSearch("example")
    super()
  end

  # Execute this search request.
  # This call is asynchronous.
  #
  # If a block is given, register it for both failure and success.
  #
  # On success, callback will receive a
  # org.elasticsearch.action.search.SearchResponse
  def execute(&block)
    use_callback(&block) if block_given?

    # TODO(sissel): allow doing other queries and such.
    qbuilder = org.elasticsearch.index.query.xcontent.QueryStringQueryBuilder.new("*")
    @prep.setQuery(qbuilder)

    action = @prep.execute(@handler)
    return action
  end

  # Execute this index request synchronously
  # Returns org.elasticsearch.action.search.SearchResponse
  def execute!
    return @prep.execute.actionGet()
  end
end # class ElasticSearch::SearchRequest
