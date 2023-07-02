#!/bin/bash

set -e

#pwd
ls     ../../test-suite/*_wrap.c   \
       ../../test-suite/*_wrap.cxx 
       
rm -fr ../../test-suite/*_wrap.c
rm -fr ../../test-suite/*_wrap.cxx
