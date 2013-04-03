## Start with it:

Grab the latest ElasticSearch distribution, and unpack it. Set your CLASSPATH to include the *jar files in the /lib directory.

Something like the following will accomplish this:

    CLASSPATH=$(ls ./elasticsearch-0.20.6/lib/*.jar | tr '\n' ':')
    
To use from with Logstash source to get the appropriate jars for jruby-elasticsearch:

    CLASSPATH=$(ls ./elasticsearch-0.20.6/lib/*.jar | tr '\n' ':') bin/logstash irb

Then to use the library in your code:

    require "jruby-elasticsearch"
    client = ElasticSearch::Client.new

## DSL Example

    client = ElasticSearch::Client.new
    req = client.index("twitter", "tweet") do
      hello "world"     
      foo "bar"
    end

    req.execute!

    # The above will index this document:
    # {
    #   "hello": "world",
    #   "foo": "bar"<
    # }

    # Async w/ callback.
    req.execute do |response|
      puts "Response; #{response}"
    end

## Non-DSL Example:

    client = ElasticSearch::Client.new
    #                  <index  >, <type   >, <id>, <data>
    req = client.index("twitter", "fizzle2", nil, {
      "hello" => "world",
      "number" => rand(5000)
    })
    req.execute!

## More complex method of indexing.

    data = { "fizzle" => "dazzle", "pants" => "off" }
    req = client.index("twitter", "tweet", data)

    # Set up async callbacks
    done = false
    req.on(:success) do |response|
      puts "Got response: #{response.inspect}"
      done = true
    end.on(:failure) do |exception|
      puts "Got failure: #{exception.inspect}"
      puts exception.backtrace
      done = true
    end

    # Execute it, but do it asynchronously.
    req.execute

    # Wait until we are done.
    while !done
      sleep 1
    end

## Searching

    # Example 1, method chaining
    # Returns org.elasticsearch.action.search.SearchResponse
    # querys for "some query" and asks for 30 results
    client.search.query("some query").size(30).execute!

    # Example 2, DSL
    client.search do
      query "some query"

      # histogram, bucketed by 10000
      histogram "some field", 10000

      # how many results
      size 100
    end.execute do |response|
      # response == org.elasticsearch.action.search.SearchResponse
    end
