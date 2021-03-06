require 'inline'

# The File mincore extension
class File
  private 
  def self._common_code(builder)
    builder.include("<stdio.h>")
    builder.include("<stdlib.h>")
    builder.include("<sys/stat.h>")

    builder.include("<sys/types.h>")
    builder.include("<fcntl.h>")
    builder.include("<unistd.h>")
    builder.include("<sys/mman.h>")
    builder.include("<errno.h>")
    #    builder.include("<fcntl.h>")

#    builder.prefix("#define exiterr(s) { perror(s); exit(-1); }")
    builder.prefix("#define exiterr(s) { rb_sys_fail(s); }")
  end

  inline do |builder|    
    builder.include("<unistd.h>")
    builder.c_raw_singleton "
static VALUE _PAGESIZE(int argc, VALUE *argv, VALUE self) {
    int size = getpagesize();
    return rb_int_new(size);
}
"
  end
  

  inline do |builder|
    self._common_code builder
    builder.c_singleton <<-C_CODE
static VALUE  _mincore(char *filename) {
    int fd;
    struct stat st;    
    int pages;
    int PAGESIZE;
    unsigned char *pageinfo = NULL;
    void *file = NULL;
    VALUE val = rb_ary_new2(2);
    VALUE pageinfo_arr;
    int ret;
    int i;

    PAGESIZE = getpagesize();

    fd = open(filename, O_RDONLY);

    if ( fd == -1 ) {
        exiterr("can't open file"); 
    }


    if(fstat(fd, &st) == -1) { // untested path
        exiterr("fstat failed");
    }

    if(!S_ISREG(st.st_mode)) {
        errno = EBADF;
        exiterr("not a regular file");
    }
    
    if ( st.st_size == 0 ) {
       pageinfo_arr = rb_ary_new2(1);
       rb_ary_push(val, INT2FIX(0));
       rb_ary_push(val, pageinfo_arr);
       return val; // return [0, []]
    }
 
    pages = (st.st_size + PAGESIZE - 1) / PAGESIZE;
    pageinfo = calloc(sizeof(*pageinfo), pages);

    if(!pageinfo) { // untested path
        exiterr("calloc");
    }

    file = mmap(NULL, st.st_size, PROT_NONE, MAP_SHARED, fd, 0);

    if(file == MAP_FAILED) { // untested path
        free(pageinfo);
        exiterr("mmap");
    }

    ret=mincore(file, st.st_size, pageinfo);

    rb_ary_push(val, INT2FIX(ret));

    if( ret == -1) {
        rb_ary_push(val, Qnil);
    }

    pageinfo_arr = rb_ary_new2(pages);
    for(i=0; i<pages; i++) {
        VALUE status = ((pageinfo[i] & 1) ? Qtrue : Qfalse);
        rb_ary_push(pageinfo_arr, status);
    }


    rb_ary_push(val, pageinfo_arr);
    
    munmap(file, st.st_size);
    free(pageinfo);

    return val;
}
C_CODE
  end

  inline do |builder|
    self._common_code builder
    builder.c_singleton <<-C_CODE
static VALUE _cachedel(char *filename, int count) {
    int ret=0; 
    int i, fd;
    struct stat st;

    fd = open(filename, O_RDONLY);

    if(fd == -1) {
        exiterr("can't open file");
    }

    if(fstat(fd, &st) == -1) {
        exiterr("fstat failed");
    }

    if(!S_ISREG(st.st_mode)) {
        errno = EBADF;
        exiterr("not a regular file");
    }

    for(i = 0; i < count; i++) {
        ret = posix_fadvise(fd, 0, 0, POSIX_FADV_DONTNEED) ;
        if(ret) {
            exiterr("posix_fadvise failed");
        }
    }

    return rb_int_new(ret);
}
C_CODE
  end

  public

  # Returns the number of system pages required to store file in memory
  # @example Sample run - on a file of size 20KB
  #    File.open("/path/to/some/file").numpages #=> 5
  # 
  # @return [Int] number of cacheable pages
  # :nocov:
  def numpages
    pagesize = self.class.PAGESIZE
    (self.stat.size + pagesize -1 ) / pagesize
  end
  # :nocov:


  # Attempts to delete cached pages of a file, one or more times
  # 
  # @example Sample run - file pages would or would not get flushed
  #    File.cachedel("/path/to/useless/file", 2) #=> 0
  # 
  # @param filename [String] file name
  # @param count [Int] times `posix_fadvise()` will be run
  # @return [Int] execution status of the last `posix_fadvise()` call
  # :nocov:
  def self.cachedel(filename, count=1) 
    self._cachedel(filename, count)
  end
  # :nocov:
  
  # Returns page cache status for a given file.
  # Status is provided as a boolean array of size
  # ( filesize + PAGESIZE -1 ) / PAGESIZE
  #
  # @example Sample run - on a file of size 20KB
  #    File.mincore("/path/to/important/file") #=> [0, [true, true, true, false, false]]
  #    
  # @param filename [String] file name
  # @return [Int, Array] execution status and cache status array
  # :nocov:
  def self.mincore(filename)
    self._mincore(filename)
  end
  # :nocov:

  # get system page size (4096 on Intel)
  # 
  # @example - On Intel machine
  #    File.PAGESIZE #=> 4096
  #
  # @return [Int] the page size
  # :nocov:
  def self.PAGESIZE
    self._PAGESIZE
  end
  # :nocov:

  

  #this should work: http://stackoverflow.com/questions/13408136/how-can-i-dynamically-define-an-alias-method-for-a-class-method 
  #class << self
  #  alias_method :mincore, :_mincore
  #end

end

