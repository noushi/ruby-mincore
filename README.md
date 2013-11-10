ruby-mincore - Ruby bindings for Linux cache manipulation
=========================================================
[![Gem Version](https://badge.fury.io/rb/mincore.png)](http://badge.fury.io/rb/mincore)
|
[![Build Status](https://travis-ci.org/noushi/ruby-mincore.png)](https://travis-ci.org/noushi/ruby-mincore)
| 
[![Code Climate](https://codeclimate.com/github/noushi/ruby-mincore.png)](https://codeclimate.com/github/noushi/ruby-mincore)
| 
[![Dependency Status](https://gemnasium.com/noushi/ruby-mincore.png)](https://gemnasium.com/noushi/ruby-mincore)

`mincore` provides Ruby bindings for Linux cache manipulation, including cache inspection and deletion for a specific file.

This project is heavily inspired from [Feh/nocache](http://github.com/Feh/nocache).

Usage
=====

Currently, `mincore` features are implemented as class methods:

    size=File.PAGESIZE
    # 4096 
    
    File.open("/path/to/file").numpages #The only instance method
    # 5
    
    File.mincore("/path/to/file")
    # [true, true, false, false, true]
    
    File.cachedel("/path/to/file")
    # 0
    
    File.mincore("/path/to/file")
    # [true, true, false, false, true]
    
    File.cachedel("/path/to/file", 2)
    # 0
    
    File.mincore("/path/to/file")
    # [true, true, false, false, true]
    
    File.cachedel("/path/to/file", 2)
    # 0
    
    File.mincore("/path/to/file")
    # [false, false, false, false, false]

This is an illustration of the fact that `cachedel` may or may not actually purge cached pages even if run multiple times (through the second parameter).

Full documentation available in the source code ^H^H, [Ruby Doc](http://rubydoc.info/gems/mincore/File).



Status & Limitations
====================

Currently, the File class is extended as such:

- `mincore(filename)` is exported to Ruby in the form of an array of booleans corresponding to each page of the file.
- `cachedel(filename, count=1)` calls `posix_fadvise(2)` to purge all file pages from the cache
- `PAGESIZE` is a simple helper that returns the value of PAGESIZE (4KB on Intel)

The bindings are implemented using Ruby Inline, instead of the classic mkmf ext C.

There is a gem module generated, and the code is still beta.

Since `File.cachedel()` isn't guaranteed to work (no matter how many time you call it), the `test_cachedel_non_empty_file` most always succeeds without properly asserting that `posix_fadvise()` has worked. 

Also, the tests use a `./writable_tmp_dir/` directory to store the temporary test files. `/tmp` can't be used since it's 
usually a ramfs, and files will always be in cache, until they're deleted.


Supported systems
-----------------

Linux (on any arch) is supported.

FreeBSD/OpenBSD/NetBSD should work, but feedback is needed.

MacOSX requires a different set of headers to properly compile (Testers needed).

Since Debian/kFreeBSD [doesn't honor](https://github.com/Feh/nocache/issues/12) `posix_fadvise()`, `mincore` won't work.


Contributing
============
Contributions are most welcome, you know the drill:

1. Fork it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request
