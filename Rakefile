require "bundler/gem_tasks"
require 'rake/testtask'
 
Rake::TestTask.new do |t|
  t.libs << 'lib/esxi'
  t.libs << 'lib'
  t.libs << "test"
  t.libs << "test/unit"
  t.test_files = FileList['test/unit/*test.rb']
  t.verbose = false
end
