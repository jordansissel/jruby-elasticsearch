require "jruby-elasticsearch/namespace"
require "jruby-elasticsearch/request"

class ElasticSearch::SearchRequest < ElasticSearch::Request
  begin
    QueryStringQueryBuilder = org.elasticsearch.index.query.xcontent.QueryStringQueryBuilder
  rescue NameError
    # The 'xcontent' namespace was removed in elasticsearch 0.17.0
    QueryStringQueryBuilder = org.elasticsearch.index.query.QueryStringQueryBuilder
  end

  # Create a new index request.
  public
  def initialize(client)
    @client = client
    begin
      @prep = org.elasticsearch.client.action.search.SearchRequestBuilder.new(@client)
    rescue NameError
      # The 'client' namespace was removed in elasticsearch 0.19.0
      @prep = org.elasticsearch.action.search.SearchRequestBuilder.new(@client)
    end
    @indeces = []
    super()
  end # def initialize

  public
  def with(&block)
    instance_eval(&block)
    return self
  end # def with

  public
  def index(index_name)
    @indeces << index_name
  end

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
    @prep.setIndices(@indeces.to_java(:String))
    action = @prep.execute(@handler)
    return action
  end # def execute

  # Execute this index request synchronously
  # Returns an org.elasticsearch.action.search.SearchResponse
  public
  def execute!
    @prep.setIndices(@indeces.to_java(:String))
    return @prep.execute.actionGet()
  end # def execute!

  public
  def sort(field, order)
    case order
      when :asc
        order_val = org.elasticsearch.search.sort.SortOrder::ASC
      when :desc
        order_val = org.elasticsearch.search.sort.SortOrder::DESC
      else
        raise "Invalid sort order '#{order.inspect}'"
    end
    @prep.addSort(field, order_val)
    return self
  end # def sort

  public
  def query(query_string, default_operator=:and)
    # TODO(sissel): allow doing other queries and such.
    qbuilder = QueryStringQueryBuilder.new(query_string)

    operator = QueryStringQueryBuilder::Operator
    case default_operator
      when :and
        qbuilder.defaultOperator(operator::AND)
      when :or
        qbuilder.defaultOperator(operator::OR)
      else
        raise "Unknown default operator '#{default_operator.inspect}'"
    end

    @prep.setQuery(qbuilder)
    return self
  end # def query

  # Add a histogram facet to this query. Can be invoked multiple times.
  public
  def histogram(field, interval, name=nil)
    if name.nil?
      # TODO(sissel): How do we expose the name of the histogram?
      name = "#{field}_#{interval}"
    end
    # TODO(sissel): Support 'global' ?
    builder = org.elasticsearch.search.facet.histogram.HistogramFacetBuilder.new(name)
    builder.field(field)
    builder.interval(interval)
    @prep.addFacet(builder)
    return self
  end # def histogram

  public
  def terms(field, name=nil)
    if name.nil?
      # TODO(sissel): How do we expose the name of the histogram?
      name = field
    end
    # TODO(sissel): Support 'global' ?
    builder = org.elasticsearch.search.facet.terms.TermsFacetBuilder.new(name)
    builder.field(field)
    @prep.addFacet(builder)
    return self
  end # def terms

  public
  def size(s)
    @prep.setSize(s)
    return self
  end
  alias :count :size
  alias :limit :size

  public
  def from(from)
    @prep.setFrom(from)
    return self
  end
  alias :offset :from
  alias :offset :from

end # class ElasticSearch::SearchRequest
