# requires Xcode 5.0.2 to run on the CLI
XCODEBUILD := /Xcode/5.0.2/Xcode.app/Contents/Developer/usr/bin/xcodebuild
FOO := /Xcode/11
default:

clean:
	-rm -rf build/*
test:
ifeq (,$(wildcard ${XCODEBUILD}))
	echo "FAIL: must have an Xcode 5.0.2 installation at /Xcode/5.0.2/Xcode.app"
	exit 1
else
	GHUNIT_CLI=1 ${XCODEBUILD} -target Tests-iOS -configuration "Debug" -sdk iphonesimulator build
	GHUNIT_CLI=1 ${XCODEBUILD} -target Tests-iOS -configuration "AdHoc" -sdk iphonesimulator build
endif



