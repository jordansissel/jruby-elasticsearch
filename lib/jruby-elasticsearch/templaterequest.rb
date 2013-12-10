require "jruby-elasticsearch/namespace"
require "jruby-elasticsearch/request"

class ElasticSearch::DeleteIndexTemplateRequest < ElasticSearch::Request

  # Create a new DeleteIndexTemplateRequest request.
  public
  def initialize(client, template_name)
    @client = client
    @template_name = template_name
    begin
      @prep = org.elasticsearch.action.admin.indices.template.delete.DeleteIndexTemplateRequestBuilder.new(@client, @template_name)
    rescue NameError
      @logger.error("Could not create DeleteIndexTemplateRequestBuilder", :name_error => NameError.to_s)
    end
    super()
  end # def initialize

  public
  def with(&block)
    instance_eval(&block)
    return self
  end # def with

  # Execute this request.
  # This call is asynchronous.
  #
  # If a block is given, register it for both failure and success.
  #
  # On success, callback will receive a
  # org.elasticsearch.action.admin.indices.template.delete.DeleteIndexTemplateResponse
  public
  def execute(&block)
    use_callback(&block) if block_given?
    action = @prep.doExecute(@handler)
    return action
  end # def execute

end # class ElasticSearch::DeleteIndexTemplateRequest

class ElasticSearch::GetIndexTemplateRequest < ElasticSearch::Request

  # Create a new GetIndexTemplateRequest request.
  public
  def initialize(client, template_name)
    @client = client
    @template_name = template_name
    begin
      @prep = org.elasticsearch.action.admin.indices.template.get.GetIndexTemplateRequestBuilder.new(@client, @template_name)
    rescue NameError
      @logger.error("Could not create GetIndexTemplateRequestBuilder", :name_error => NameError.to_s)
    end
    super()
  end # def initialize

  public
  def with(&block)
    instance_eval(&block)
    return self
  end # def with

  # Execute this request.
  # This call is asynchronous.
  #
  # If a block is given, register it for both failure and success.
  #
  # On success, callback will receive a
  # org.elasticsearch.action.admin.indices.template.get.GetIndexTemplateResponse
  public
  def execute(&block)
    use_callback(&block) if block_given?
    action = @prep.doExecute(@handler)
    return action
  end # def execute

end # class ElasticSearch::GetIndexTemplateRequest
