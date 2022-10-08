#/!sh

rm -rf build
mkdir build
dart compile exe bin/cmt.dart -o build/cmt
