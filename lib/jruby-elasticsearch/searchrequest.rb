require "jruby-elasticsearch/namespace"
require "jruby-elasticsearch/request"

class ElasticSearch::SearchRequest < ElasticSearch::Request
  # Create a new index request.
  public
  def initialize(client)
    @client = client
    @prep = @client.prepareSearch("example")
    super()
  end # def initialize

  # Execute this search request.
  # This call is asynchronous.
  #
  # If a block is given, register it for both failure and success.
  #
  # On success, callback will receive a
  # org.elasticsearch.action.search.SearchResponse
  public
  def execute(&block)
    use_callback(&block) if block_given?

    # TODO(sissel): allow doing other queries and such.
    qbuilder = org.elasticsearch.index.query.xcontent.QueryStringQueryBuilder.new("*")
    @prep.setQuery(qbuilder)

    action = @prep.execute(@handler)
    return action
  end # def execute

  # Execute this index request synchronously
  # Returns org.elasticsearch.action.search.SearchResponse
  public
  def execute!
    return @prep.execute.actionGet()
  end # def execute!

  public
  def sort(field, order)
    case order
      when :asc
        order_val = org.elasticsearch.search.sort.SortOrder::ASC
      when :desc
        order_val = org.elasticsearch.search.sort.SortOrder::DESC
    end
    return @prep.addSort(field, order_val)
  end # def sort

  public
  def query(query_string)
    return @prep.setQuery(query_string)
  end # def query
end # class ElasticSearch::SearchRequest
