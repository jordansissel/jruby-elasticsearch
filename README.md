
DSL Example ideas:

    client = ElasticSearch::Client.new
    req = client.index("twitter", "tweet") do
      hello "world"     
      foo "bar"
    end

    # The above will index this document:
    # {
    #   "hello": "world",
    #   "foo": "bar"<
    # }

    # Synchronous
    req.execute

    # Async w/ callback.
    req.execute do |response|
      puts "Document indexed!"
    end

Non-DSL Example:

    #                  <index  >, <type   >, <id>, <data>
    req = client.index("twitter", "fizzle2", nil, {
      "hello" => "world",
      "number" => rand(5000)
    })
    req.execute
