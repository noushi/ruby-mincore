#!/usr/bin/env ruby
# Simple script to view the cached'ness of a (single) file.

require 'mincore'

filename=ARGV[0]

retcode, pieces = File.mincore(filename)

cached=0
pieces.each do |e|
  cached += 1 if e
end

puts "#{cached}/#{pieces.size}"


