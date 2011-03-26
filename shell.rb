# Require all the elasticsearch libs
["/home/jls/projects/logstash/test/setup/elasticsearch/**/*.jar",
 "/home/jls/projects/logstash/vendor/jar/elasticsearch*/*.jar"].each do |path|
  Dir.glob(path).each do |jar|
    require jar
  end
end

$:.unshift("lib")

require "jruby-elasticsearch"
