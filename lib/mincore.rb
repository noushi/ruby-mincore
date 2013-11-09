require 'inline'

# The File mincore extension
class File
  def self._common_code(builder)
    builder.include("<stdio.h>")
    builder.include("<stdlib.h>")
    builder.include("<sys/stat.h>")

    builder.include("<sys/types.h>")
    builder.include("<fcntl.h>")
    builder.include("<unistd.h>")
    builder.include("<sys/mman.h>")
    #    builder.include("<fcntl.h>")
    #    builder.include("<fcntl.h>")

    builder.prefix("#define exiterr(s) { perror(s); exit(-1); }")
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
//    fprintf(stderr, "running fstat() on %s", filename);



    if(fstat(fd, &st) == -1)
        exiterr("fstat");
    if(!S_ISREG(st.st_mode)) {
        fprintf(stderr, "%s: S_ISREG: not a regular file", filename);
        return EXIT_FAILURE;
    }
    
    if ( st.st_size == 0 ) {
       pageinfo_arr = rb_ary_new2(1);
       rb_ary_push(val, INT2FIX(0));
       rb_ary_push(val, pageinfo_arr);
       return val; // return [0, []]
    }
 
    pages = (st.st_size + PAGESIZE - 1) / PAGESIZE;
    pageinfo = calloc(sizeof(*pageinfo), pages);

    if(!pageinfo) {
        exiterr("calloc");
    }

    file = mmap(NULL, st.st_size, PROT_NONE, MAP_SHARED, fd, 0);

    if(file == MAP_FAILED) {
        exiterr("mmap");
    }

    ret=mincore(file, st.st_size, pageinfo);

    rb_ary_push(val, INT2FIX(ret));

    if( ret == -1) {
        rb_ary_push(val, Qnil);
    }

    pageinfo_arr = rb_ary_new2(pages);
    for(i=0; i<pages; i++) {
//        VALUE status = ((pageinfo[i] & 1)?Qtrue:Qfalse);
        VALUE status = Qtrue;
        rb_ary_push(pageinfo_arr, status);
    }


    rb_ary_push(val, pageinfo_arr);
    
//    val = (long long) st.st_size;
//    fprintf (stderr, "val=%d\\n", val);    

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
        exiterr("open");
    }

    if(fstat(fd, &st) == -1) {
        exiterr("fstat");
    }

    if(!S_ISREG(st.st_mode)) {
        fprintf(stderr, "%s: S_ISREG: not a regular file", filename);
        ret = -1;
    }

    for(i = 0; i < count; i++) {
        if(posix_fadvise(fd, 0, 0, POSIX_FADV_DONTNEED) == -1) {
            exiterr("posix_fadvise");
        }
    }

    return rb_int_new(ret);
}
C_CODE
  end

  # Returns the number of system pages required to store file in memory
  def numpages
    pagesize = self.class.PAGESIZE
    (self.stat.size + pagesize -1 ) / pagesize
  end


  # Attempts to delete cached pages of a file, one or more times
  # 
  # Example:
  #    >> File.cachedel("/path/to/useless/file", 2)
  #    => 0
  # 
  # Arguments:
  #   filename: (String)
  #   count: (Int)
  #
  def self.cachedel(filename, count=1) 
    self._cachedel(filename, count)
  end
  
  # Returns page cache status for a given file.
  # Status is provided as a boolean array of size
  # ( filesize + PAGESIZE -1 ) / PAGESIZE
  #
  # Example: 
  #    >> File.mincore("/path/to/important/file")
  #    => [true, true, true....]
  # 
  # Arguments:
  #   filename: (String)
  #
  def self.mincore(*args)
    self._mincore(*args)
  end

  # get system pagesize (4096 on Intel)
  # 
  # Example:
  #    >> File.PAGESIZE
  #    => 4096
  def self.PAGESIZE
    self._PAGESIZE
  end

  

  #this should work: http://stackoverflow.com/questions/13408136/how-can-i-dynamically-define-an-alias-method-for-a-class-method 
  #class << self
  #  alias_method :mincore, :_mincore
  #end

end

