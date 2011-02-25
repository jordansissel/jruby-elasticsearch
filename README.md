
## Start with it:

    require "elasticsearch"
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
