require "jruby-elasticsearch/namespace"

class ElasticSearch::BulkStream
  def initialize
    @bulkthread = Thread.new
  end
end
