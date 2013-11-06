Gem::Specification.new do |s|
  s.name        = 'mincore'
  s.version     = '0.0.7'
  s.date        = '2013-11-06'
  s.summary     = "Ruby bindings for Linux cache manipulation"
  s.description = "Provides cache inspection and deletion for a specific file."
  s.authors     = ["Reda NOUSHI"]
  s.email       = 'reda_noushi@yahoo.com'
  s.files       = ["lib/mincore.rb"]
  s.homepage    =
    'http://github.com/noushi/ruby-mincore'
  s.add_runtime_dependency "RubyInline", ["~> 3.10.1"]
  s.add_development_dependency "RubyInline", ["~> 3.10.1"]
  s.license       = 'GPLv2'
end
