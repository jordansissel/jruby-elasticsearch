require "test/unit"

class TestElasticSearch < Test::Unit::TestCase
  def setup
    # Require all the elasticsearch libs
    raise "Please set ELASTICSEARCH_HOME" if ENV['ELASTICSEARCH_HOME'].nil?
    Dir[File.join(ENV['ELASTICSEARCH_HOME'],"lib/*.jar")].each do |jar|
      require jar
    end

    $:.unshift("lib")
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
    bulk = @client.bulk_index
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
end
