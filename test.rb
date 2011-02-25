# Require all the elasticsearch libs
Dir["/home/jls/build/elasticsearch-0.15.0//lib/*.jar"].each do |jar|
  require jar
end

$:.unshift("lib")
require "elasticsearch"

# Create a client which will find a nearby elasticsearch cluster using
# the default discovery mechanism.
client = ElasticSearch::Client.new

## Simple method of indexing, using a dsl-like thingy:
# The 'execute!' method is synchronous.
client.index("twitter", "tweet") do
  hello "world"
  foo "bar"
end.execute!

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
