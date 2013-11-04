require File.dirname(__FILE__) + '/test_helper'

require 'fileutils'
require 'mincore'

class TestableFile
  attr_accessor :path, :size, :name
  
  def initialize(size=100, path='/tmp')
    @path = path
    @size = size
    @name = "#{@path}/testable_file.#{rand(1000000)}"
    FileUtils.touch(@name)  
  end
  
  def fill
    File.open(@name, "w") do |f|
#      s = Random.new.bytes(1024)
      s = "s" * 1024
      f.write(s * size)
    end
  end
  

  def read(pages=@size)
    
    
  end


  def delete
    File.delete(@name)
  end

  def describe
    "file #{@name} of current size #{File.stat(@name).size}"
  end

end

class MincoreTest < Test::Unit::TestCase
  def test_pagesize
    pagesize = `getconf PAGESIZE`.to_i
    assert_equal pagesize, File.PAGESIZE
  end
  
  def test_mincore_empty_file
#    _generic_mincore_test 0, [0,[]]
  end

  def test_mincore_non_empty_file
    _generic_mincore_test 40
  end

  def _generic_mincore_test(size_kb, result=nil)
    size = size_kb * 1024
    pagesize = File.PAGESIZE
    num_pages = (size + pagesize -1 ) / pagesize

    f = TestableFile.new(size_kb)


    retcode, pieces = File.mincore(f.name)
    
    assert_equal [0, []], [retcode, pieces] 

    return if size == 0
    
    f.fill

    retcode, pieces = File.mincore(f.name)

    assert_equal retcode, 0, f.describe
    assert_equal [true]*num_pages, pieces

    f.delete
  end
  
  
  
  
end
