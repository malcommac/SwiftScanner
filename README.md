<p align="center" >
  <img src="https://raw.githubusercontent.com/malcommac/SwiftScanner/develop/swift_scanner_logo.png" width=200px height=219px alt="SwiftScanner" title="SwiftScanner">
</p>

[![Build Status](https://travis-ci.org/oarrabi/SwiftScanner.svg?branch=master)](https://travis-ci.org/oarrabi/SwiftScanner)
[![codecov](https://codecov.io/gh/oarrabi/SwiftScanner/branch/master/graph/badge.svg)](https://codecov.io/gh/oarrabi/SwiftScanner)
[![Platform](https://img.shields.io/badge/platform-osx-lightgrey.svg)](https://travis-ci.org/oarrabi/SwiftScanner)
[![Platform](https://img.shields.io/badge/platform-ios-lightgrey.svg)](https://travis-ci.org/oarrabi/SwiftScanner)
[![Language: Swift](https://img.shields.io/badge/language-swift-orange.svg)](https://travis-ci.org/oarrabi/SwiftScanner)
[![CocoaPods](https://img.shields.io/cocoapods/v/SwiftScanner.svg)](https://cocoapods.org/pods/SwiftScanner)
[![Carthage](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)


# SwiftScanner
`StringScanner` is a pure native Swift implementation of a string scanner; with no dependecies, full unicode support (who does not love emoji?), lots of useful featurs and swift in mind, StringScanner is a good alternative to built-in Apple's `NSScanner`.

<p align="center" >★★ <b>Star our github repository to help us!</b> ★★</p>

## Main Features
SwiftScanner is initialized with a string and mantain an internal index used to navigate backward and forward through the string using two main concepts:

* `scan` to return string which also increment the internal index
* `peek` to return a string without incrementing the internal index

Results of these operations returns collected String or Indexes.
If operation fail due to an error (ie. `eof`, `notFound`, `invalidInt`...) and exception is thrown, in pure Swift style.

## Documentation

### All `scan` functions

#### `public func scanChar() throws -> UnicodeScalar`
`scanChar` allows you to scan the next character after the current's scanner `position` and return it as `UnicodeScalar`.
If operation succeded internal scanner's `position` is advanced by 1 character (as unicode).
If operation fails an exception is thrown.

#### `public func scanInt() throws -> Int`
Scan the next integer value after the current scanner's `position`; consume scalars from {0...9} until a non numeric value is encountered. Return the integer representation in base 10.
Throw `.invalidInt` if scalar at current position is not in allowed range.
If operation succeded internal scanner's `position` is advanced by the number of character which represent an integer.
If operation fails an exception is thrown.

#### `public func scanFloat() throws Float`
