default:

clean:
	-rm -rf build/*
test:
	GHUNIT_CLI=1 xcodebuild -target Tests-iOS -configuration "Debug" -sdk iphonesimulator build
	GHUNIT_CLI=1 xcodebuild -target Tests-iOS -configuration "AdHoc" -sdk iphonesimulator build



