#!/usr/bin/env ruby
# Simple script to _attempt_ to purge the cached pages of a (single) file.

require 'mincore'

def process_errno(e)
  puts e.message
  exit 1
end

def process_unknown_exception(e)
  puts "Unknown caught exception: #{e.message}"
  exit 1
end

def process_file(filename)
  begin 
    retcode = File.cachedel(filename, 2)
    puts "retcode=#{retcode}" if ENV["DEBUG"]
    exit retcode unless retcode == 0
  rescue Errno::EBADF => e
    process_errno e
  rescue Errno::EACCES => e
    process_errno e
  rescue Exception => e
    process_unknown_exception e
  end
end

process_file(ARGV[0])

