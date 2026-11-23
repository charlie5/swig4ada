/* A binding to LevelDB, from its own headers: a class library which nobody wrote as a test. */

%module leveldb

%include <std_string.i>

%{
#include <leveldb/db.h>
#include <leveldb/comparator.h>
#include <leveldb/write_batch.h>
#include <leveldb/cache.h>
#include <leveldb/filter_policy.h>
#include <leveldb/env.h>
#include "example.h"
%}

#define LEVELDB_EXPORT

%include <leveldb/slice.h>
%include <leveldb/status.h>
%include <leveldb/comparator.h>
%include <leveldb/iterator.h>
%include <leveldb/options.h>
%include <leveldb/write_batch.h>
%include <leveldb/db.h>

%include "example.h"
