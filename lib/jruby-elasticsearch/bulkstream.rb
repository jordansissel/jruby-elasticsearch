require "jruby-elasticsearch/namespace"
require "thread"

class ElasticSearch::BulkStream
  # Create a new bulk stream. This allows you to send
  # index and other bulk events asynchronously and use
  # the bulk api in ElasticSearch in a streaming way.
  #
  # The 'queue_size' is the maximum size of unflushed
  # requests. If the queue reaches this size, new requests
  # will block until there is room to move.
  def initialize(client, queue_size=10, flush_interval=1)
    @bulkthread = Thread.new { run } 
    @client = client
    @queue_size = queue_size
    @queue = SizedQueue.new(@queue_size)
    @flush_interval = flush_interval
  end # def initialize

  # See ElasticSearch::BulkRequest#index for arguments.
  public
  def index(*args)
    # TODO(sissel): It's not clear I need to queue this up, I could just
    # call BulkRequest#index() and when we have 10 or whatnot, flush, but
    # Queue gives us a nice blocking mechanism anyway.
    @queue << [:index, *args]
  end # def index

  # The stream runner. 
  private
  def run
    # TODO(sissel): Make a way to shutdown this thread.
    while true
      requests = []
      if @queue.size == @queue_size
        # queue full, flush now.
        flush
      else
        # Not full, so sleep and flush anyway.
        sleep(@flush_interval)
        flush
      end

      if @stop and @queue.size == 0
        break
      end
    end # while true
  end # def run

  # Stop the stream
  public
  def stop
    @stop = true
  end # def stop

  # Flush the queue right now. This will block until the
  # bulk request has completed.
  public
  def flush
    bulk = @client.bulk
    1.upto(@queue.size) do |method, *args|
      # calls bulk.index(*args) if method is index, etc...
      bulk.send(method, *args)
    end

    # Block until this finishes
    bulk.execute!
  end # def flush
end # class ElasticSearch::BulkStream
