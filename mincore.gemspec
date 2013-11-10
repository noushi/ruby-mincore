Gem::Specification.new do |s|
  s.name        = 'mincore'
  s.version     = '0.0.9.pre'
  s.date        = '2013-11-10'

  s.homepage    = 'http://github.com/noushi/ruby-mincore'
  s.summary     = "Ruby bindings for Linux cache manipulation"
  s.description = <<-DESC
    micore provides Ruby bindings for Linux cache manipulation, 
    including cache inspection and deletion for a specific file.
  DESC
  s.license       = 'GPL-2'

  s.authors     = ["Reda NOUSHI"]
  s.email       = 'reda_noushi@yahoo.com'

  s.files       = `git ls-files`.split($/)
  #s.files       = ["lib/mincore.rb"]
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})

  s.add_runtime_dependency "RubyInline", [">= 3.10.1"]
  s.add_development_dependency "RubyInline", [">= 3.10.1"]
end
