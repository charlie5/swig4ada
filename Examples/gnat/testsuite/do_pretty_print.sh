#!/bin/bash

set -e

gnatpp -rnb -I../../../..  *.ads    -cargs  -gnatX

