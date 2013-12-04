require 'rake/testtask'

task :package do
  system("gem build jruby-elasticsearch.gemspec")
end

task :publish do
  latest_gem = %x{ls -t jruby-elasticsearch-[0-9]*.gem}.split("\n").first
  system("gem push #{latest_gem}")
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end
