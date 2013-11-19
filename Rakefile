require 'rake/testtask'
require 'rake/clean'

WORKDIR='writable_tmp_dir'

CLEAN.include("#{WORKDIR}/*")
CLEAN.include("coverage")

Rake::TestTask.new(:ci_test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

task :alcove do
  ENV["LOCAL_COVERAGE"]="ENABLE"
  Rake::Task["clean"].invoke
  Rake::Task["test"].invoke
end


task :test do
  ENV["COVERALLS"]="DISABLE"
  Rake::Task["ci_test"].invoke
end

task :default => :test

