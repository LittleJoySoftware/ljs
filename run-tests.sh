#!/bin/sh

/usr/bin/osascript -e 'tell application "iPhone Simulator" to quit'

cd Tests-MacOS

make clean && WRITE_JUNIT_XML=YES make test
RETVAL=`echo $?`
if [ $RETVAL = 0 ]; then
  echo "NOTE: MacOS unit tests passed"
else
  echo "FAIL: MacOS unit tests failed"
  exit $RETVAL
fi

cd ..

cd Tests-iOS
make clean && WRITE_JUNIT_XML=YES make test

if [ $RETVAL = 0 ]; then
  echo "NOTE: iOS unit tests passed"
else
  echo "FAIL: iOS unit tests failed"
  exit $RETVAL
fi


echo "NOTE: *********************************"
echo "NOTE: LJS MacOS unit tests passed"
echo "NOTE: LJS iOS unit tests passed"
echo "NOTE: LJS is safe to push to github"
echo "NOTE: *********************************"

exit $RETVAL



