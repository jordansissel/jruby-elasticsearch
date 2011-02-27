require 'tempfile'

task :package do
  system("gem build jruby-elasticsearch.gemspec")
end

task :publish do
  latest_gem = %x{ls -t jruby-elasticsearch-[0-9]*.gem}.split("\n").first
  system("gem push #{latest_gem}")
end

task :test do
    system("cd test; ruby run.rb")
end

