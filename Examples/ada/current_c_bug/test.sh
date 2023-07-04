#!/bin/bash

set -e

echo
echo Building ...
gprbuild tester.adb -largs example_wrap.o

echo
echo Running ...
./tester

echo
echo Done.
