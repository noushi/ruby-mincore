if ENV["LOCAL_COVERAGE"] == "ENABLE"
  require 'simplecov'
  type = "Unit Tests" #or "Unit Tests" #or "MiniTest"
  SimpleCov.command_name type
  SimpleCov.start do 
    add_filter "/test/"
  end
end

Dir.chdir File.expand_path("../../", __FILE__)
$LOAD_PATH.unshift ".", "lib", "test"

require "test/unit"

class Array
  def tinify
    cur = nil
    ret = []
    self.each_index { |x| 
      if x == 0
        cur = self[x]
        ret << [self[x],1]
        next 
      end
      
      if cur == self[x]
#        puts "<#{ret.last}>"
        ret[-1][1] += 1
      else
        ret << [self[x],1]
      end

      cur = self[x]
    }
    ret
  end
end


unless ENV["COVERALLS"] == "DISABLE"
  require 'coveralls'
  Coveralls.wear!
end
