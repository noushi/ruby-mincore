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
  
  def numpages
    File.open(@name).numpages
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
    `dd if=#{@name} of=/dev/null bs=#{File.PAGESIZE} count=#{pages}`
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

  def test_numpages
    size_kb = rand(1000)
    f = TestableFile.new(size_kb, "./writable_tmp_dir")
    pagesize = File.PAGESIZE
    
    numpages = (File.open(f.name).stat.size*1024 + pagesize -1 ) / pagesize
    
    assert_equal numpages, f.numpages

    f.delete
  end
  
  def test_mincore_empty_file
    _generic_mincore_test 0, [0,[]], :delete => true
  end

  def test_mincore_non_empty_file
    _generic_mincore_test 40, :delete => true
  end

  def test_mincore_devnull
    assert_raise(Errno::EBADF) { File.mincore("/dev/null") }
  end

  # don't run this as root, mincore() will succeed!
  def test_mincore_etcshadow
    assert_raise(Errno::EACCES) { File.mincore("/etc/shadow") }
  end

  def test_cachedel_empty_file
    _generic_cachedel_test 0
  end

  # This test works when the file size is big enough (worked with 4MB and 40MB).
  # On smaller files, file keeps being cached (tried with <400KB)
  def test_cachedel_non_empty_file
    _generic_cachedel_test 4000
  end

  def test_cachedel_devnull
    assert_raise(Errno::EBADF) { File.cachedel("/dev/null") }
  end

  # don't run this as root, mincore() will succeed!
  def test_cachedel_etcshadow
    assert_raise(Errno::EACCES) { File.cachedel("/etc/shadow") }
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
    assert_equal [[true, f.numpages]], pieces.tinify

    f.delete if delete

    return f
  end
  
  def _generic_cachedel_test(size_kb)
    f=_generic_mincore_test(size_kb, nil, false)
    
    f.read

    retcode, pieces = File.mincore(f.name)

    assert_equal retcode, 0, f.describe
    assert_equal [true]*(f.numpages), pieces

    ret = File.cachedel(f.name, 30)
    assert_equal 0, ret, f.describe
    
    #`cachedel #{f.name}`
   
    retcode, pieces = File.mincore(f.name)

    assert_equal retcode, 0, f.describe

    if size_kb == 0
      ret = []
      assert_equal ret, pieces.tinify, f.describe
    else
      ret = [[true, f.numpages]]
      feeling_lucky = true # see test_cachedel_non_empty_file() doc to understand this
      if feeling_lucky or ret != pieces.tinify #The code/test is still valid even if the file is fully kept cached
        assert_not_equal ret, pieces.tinify, f.describe
      end
    end
    
    f.delete

  end


  
  
  
end
