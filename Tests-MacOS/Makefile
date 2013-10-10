default:

clean:
	-rm -rf build/*

test:
	GHUNIT_CLI=1 xcodebuild -target Tests-MacOS -configuration "Debug" -sdk macosx10.8 build
	GHUNIT_CLI=1 xcodebuild -target Tests-MacOS -configuration "Release" -sdk macosx10.8 build
