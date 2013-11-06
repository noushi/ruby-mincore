ruby-mincore
============
[![Gem Version](https://badge.fury.io/rb/mincore.png)](http://badge.fury.io/rb/mincore)
[![Build Status](https://travis-ci.org/noushi/ruby-mincore.png?branch=master)](https://travis-ci.org/noushi/ruby-mincore)

Ruby bindings for Linux cache manipulation

This project is heavily inspired from Feh/nocache .


Status & Limitations
====================

Currently, the File class is extended as such:
- mincore() is exported to Ruby in the form of an array of booleans corresponding to each page of the file.
- cachedel() calls `posix_fadvise(2)` to purge all file pages from the cache
- PAGESIZE() is a simple helper that returns the value of PAGESIZE (4KB on Intel)

The bindings are implemented using Ruby Inline, instead of the classic mkmf ext C.

There is a gem module generated, and the code is still alpha.

Since File.cachedel() isn't guaranteed to work (no matter how many time you call it), the `test_cachedel_non_empty_file` 
test case still fails.

Also, the tests use a `./writable_tmp_dir/` directory to store the temporary test files. `/tmp` can't be used since it's 
usually a ramfs, and files will always be in cache, until they're deleted.


