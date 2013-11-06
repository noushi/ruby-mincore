require File.dirname(__FILE__) + '/test_helper'

require 'fileutils'
require 'mincore'

class TestableFile
  attr_reader :path, :size, :name
  
  def initialize(size_kb=100, path='/tmp')

    @path = path
    FileUtils.mkdir_p(@path) unless File.directory?(@path)

    @size_kb = size_kb

    @name = "#{@path}/testable_file.#{rand(1000000)}"
    FileUtils.touch(@name)  
  end
  
  def num_pages
    pagesize = File.PAGESIZE
    (@size_kb*1024 + pagesize -1 ) / pagesize
  end
  


  def cli_fill
    @size_kb.times do 
      s = "s" * 1024
      `echo -n #{s} >>#{@name}`
    end
  end

  def ruby_fill
    File.open(@name, "w") do |f|
#      s = Random.new.bytes(1024)
      s = "s" * 1024
      @size_kb.times do 
        f.write s
      end
    end
  end
  
  alias_method :fill, :ruby_fill
#  alias_method :fill, :cli_fill

  def read(pages=@size_kb)
    if pages == @size_kb
      `cat #{@name} >/dev/null`
    else
      4.times do 
        File.open(@name, "r").each do |line|
          line
        end
      end
    end
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
    _generic_mincore_test 0, [0,[]], :delete => true
  end

  def test_mincore_non_empty_file
    _generic_mincore_test 40, :delete => true
  end

  def test_cachedel_empty_file
    _generic_cachedel_test 0
  end

  def test_cachedel_non_empty_file
    _generic_cachedel_test 400
  end


  def _generic_mincore_test(size_kb, result=nil, delete=true)
    size = size_kb * 1024

    f = TestableFile.new(size_kb, "./writable_tmp_dir")

    retcode, pieces = File.mincore(f.name)
    
    assert_equal [0, []], [retcode, pieces] 

    return f if size == 0
    
    f.fill

    retcode, pieces = File.mincore(f.name)

    assert_equal retcode, 0, f.describe
    assert_equal [true]*f.num_pages, pieces

    f.delete if delete

    return f
  end
  
  def _generic_cachedel_test(size_kb)
    f=_generic_mincore_test(size_kb, nil, false)
    
    f.read

    retcode, pieces = File.mincore(f.name)

    assert_equal retcode, 0, f.describe
    assert_equal [true]*(f.num_pages), pieces

    ret = File.cachedel(f.name, 30)
    assert_equal 0, ret, f.describe
    
    #`cachedel #{f.name}`
   
    retcode, pieces = File.mincore(f.name)

    assert_equal retcode, 0, f.describe

    if size_kb == 0
      ret = []
      assert_equal ret, pieces.tinify, f.describe
    else
      ret = [[true, f.num_pages]]
      if ret != pieces.tinify #The code/test is still valid even if the file is fully kept cached
        assert_not_equal ret, pieces.tinify, f.describe
      end
    end
    
    f.delete

  end


  
  
  
end
