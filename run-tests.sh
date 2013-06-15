#!/bin/sh
PWD=`pwd`
CC=
/usr/bin/osascript -e 'tell application "iPhone Simulator" to quit'


cd Tests-MacOS
make clean && WRITE_JUNIT_XML=YES make test

cd "${PWD}"
#make clean && WRITE_JUNIT_XML=YES make test


