# Require all the elasticsearch libs
Dir["/home/jls/projects/logstash/vendor/jar/**/*.jar"].each do |jar|
  require jar
end

$:.unshift("lib")
