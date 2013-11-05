require 'rake/testtask'
require 'rake/clean'

WORKDIR='writable_tmp_dir'

CLEAN.include("#{WORKDIR}/*")

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end




task :default => :test

