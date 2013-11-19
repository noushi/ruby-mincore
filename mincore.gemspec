Gem::Specification.new do |s|
  s.name        = 'mincore'
  s.version     = '0.0.9.3.pre.4'
  s.date        = '2013-11-19'

  s.homepage    = 'http://github.com/noushi/ruby-mincore'
  s.summary     = "Ruby bindings for Linux cache manipulation"
  s.description = <<-DESC
    mincore provides Ruby bindings for Linux cache manipulation, 
    including cache inspection and deletion for a specific file.
    IMPORTANT : versions <= 0.0.9.2 have a buggy File.mincore(),	
    	        0.0.9.3 and upwards work.
  DESC
  s.license       = 'GPL-2'

  s.authors     = ["Reda NOUSHI"]
  s.email       = 'reda_noushi@yahoo.com'

  s.files       = `git ls-files`.split($/)
  #s.files       = ["lib/mincore.rb"]
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})

  s.executables << "cachestats.rb"

  s.add_runtime_dependency "RubyInline", [">= 3.10.1"]
  s.add_development_dependency "RubyInline", [">= 3.10.1"]
end
