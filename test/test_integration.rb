require "test/unit"

class TestElasticSearch < Test::Unit::TestCase
  def setup
    # Require all the elasticsearch libs
    raise "Please set ELASTICSEARCH_HOME" if ENV['ELASTICSEARCH_HOME'].nil?

    dir = File.join(ENV["ELASTICSEARCH_HOME"], "lib")
    if !File.directory?(dir)
      raise "ELASTICSEARCH_HOME set, but #{dir} doesn't exist"
    end

    Dir.glob(File.join(dir, "*.jar")).each do |jar|
      require jar
    end

    $:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
    require "jruby-elasticsearch"

    # Start a local elasticsearch node
    builder = org.elasticsearch.node.NodeBuilder.nodeBuilder
    builder.local(true)
    @elasticsearch = builder.node
    @elasticsearch.start

    # Create a client which will find a nearby elasticsearch cluster using
    # the default discovery mechanism.
    @client = ElasticSearch::Client.new({:type => :local})
  end

  def test_index_asynchronously
    data = { "fizzle" => "dazzle", "pants" => "off" }
    req = @client.index("twitter", "tweet", data)

    # Set up async callbacks
    done = false
    req.on(:success) do |response|
      assert_not_nil response
      done = true
    end.on(:failure) do |exception|
      raise exception
      done = true
    end

    # Execute it, but do it asynchronously.
    req.execute

    # Wait until we are done.
    while !done
      sleep 1
    end
  end

  def test_bulk_index_asynchronously
    data = { "fizzle" => "dazzle", "pants" => "off" }
    bulk = @client.bulk
    bulk.index("twitter", "tweet1", data)
    bulk.index("twitter", "tweet2")

    # Set up async callbacks
    done = false
    bulk.on(:success) do |response|
      assert_not_nil response
      done = true
    end.on(:failure) do |exception|
      raise exception
      done = true
    end

    # Execute it, but do it asynchronously.
    bulk.execute

    # Wait until we are done.
    while !done
      sleep 1
    end
  end

  def test_bulk_stream_synchronous
    stream = @client.bulkstream(10)
    tries = 10
    entries = 30
    1.upto(entries) do |i|
      stream.index("hello", "world", { "foo" => "bar", "i" => i })
    end
    stream.stop

    found = false
    1.upto(tries) do
      search = @client.search do
        index "hello"
        query "*"
      end
      # Results is an org.elasticsearch.action.search.SearchResponse
      results = search.execute!
      count = results.hits.totalHits

      if count == entries
        # assert for good measure
        found = true
        break
      end
      sleep 0.2
    end # try a bunch to find our results

    assert(found, "Search results were not found.")
  end # def test_bulk_stream_synchronous
end # class TestElasticSearch
