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

### `scan` functions

#### `public func scanChar() throws -> UnicodeScalar`
`scanChar` allows you to scan the next character after the current's scanner `position` and return it as `UnicodeScalar`.
If operation succeded internal scanner's `position` is advanced by 1 character (as unicode).
If operation fails an exception is thrown.

Example:
```swift
let scanner = StringScanner("Hello this is SwiftScanner")
let firstChar = try! scanner.scanChar() // get 'H'
```

#### `public func scanInt() throws -> Int`
Scan the next integer value after the current scanner's `position`; consume scalars from {0...9} until a non numeric value is encountered. Return the integer representation in base 10.
Throw `.invalidInt` if scalar at current position is not in allowed range (may also return `.eof`).
If operation succeded internal scanner's `position` is advanced by the number of character which represent an integer.
If operation fails an exception is thrown.

Example:
```swift
let scanner = StringScanner("I've 15 apples")
let parsedInt = try! scanner.scanChar() // get Int=15
```

#### `public func scanFloat() throws -> Float`
Scan for a float value (in format ##.##) and convert it to a valid Floast.
If scan succeded scanner's `position` is updated at the end of the represented string, otherwise an exception (`.invalidFloat`, `.eof`) is thrown and index is not touched.

Example:
```swift
let scanner = StringScanner("I've 45.54 $")
let parsedFloat = try! scanner.scanFloat() // get Int=45.54
```

#### `public func scanHexInt(digits: BitDigits) throws -> Int`
Scan an HEX digit expressed in these formats:

* `0x[VALUE]` (example: `0x0000000000564534`)
* `0X[VALUE]` (example: `0x0929`)
* `#[VALUE]` (example: `#1602`)

If scan succeded scanner's `position` is updated at the end of the represented string, otherwise an exception ((`.notFound`, )`.invalidHex`, `.eof`) is thrown and index is not touched.

Example:
```swift
let scanner = StringScanner("#1602")
let value = try! scanner.scanHexInt(.bit16) // get Int=5634

let scanner = StringScanner("#0x0929")
let value = try! scanner.scanHexInt(.bit16) // get Int=2345

let scanner = StringScanner("#0x0000000000564534")
let value = try! scanner.scanHexInt(.bit64) // get Int=5653812
```
#### `public func scan(upTo char: UnicodeScalar) throws -> String?`
Scan until given character is found starting from current scanner `position` till the end of the source string.
Scanner's `position` is updated only if character is found and set just before it.
Throw an exception if `.eof` is reached or `.notFound` if char was not found (in this case scanner's position is not updated)

Example:
```swift
let scanner = StringScanner("Hello <bold>Daniele</bold>")
let partialString = try! scanner.scan(upTo: "<bold>") // get "Hello "
```
#### `public func scan(upTo charSet: CharacterSet) throws -> String?`
Scan until given character's is found.
Index is reported before the start of the sequence, scanner's `position` is updated only if sequence is found.
Throw an exception if `.eof` is reached or `.notFound` if sequence was not found.

Example:
```swift
let scanner = StringScanner("Hello, I've at least 15 apples")
let partialString = try! scanner.scan(upTo: CharacterSet.decimalDigits) // get "Hello, I've at least "
```

#### `public func scan(untilIn charSet: CharacterSet) throws -> String?`
Scan, starting from scanner's `position` until the next character of the scanner is contained into given character set.
Scanner's `position` is updated automatically at the end of the sequence if validated, otherwise it will not touched.

Example:
```swift
let scanner = StringScanner("HELLO i'm mark")
let partialString = try! scanner.scan(untilIn: CharacterSet.lowercaseLetters) // get "HELLO"
```

#### `public func scan(upTo string: String) throws -> String?`
Scan, starting from scanner's `position`  until specified string is encountered.
Scanner's `position` is updated automatically at the end of the sequence if validated, otherwise it will not touched.

Example:
```swift
let scanner = StringScanner("This is a simple test I've made")
let partialString = try! scanner.scan(upTo: "I've") // get "This is a simple test "
```
#### `public func scan(untilTrue test: ((UnicodeScalar) -> (Bool))) -> String`
Scan and consume at the scalar starting from current `position`, testing it with function test.
If test returns `true`, the `position` increased.
If `false`, the function returns.

Example:
```swift
let scanner = StringScanner("Never be satisfied 💪 and always push yourself! 😎 Do the things people say cannot be done")
let delimiters = CharacterSet(charactersIn: "💪😎")
while !scanner.isAtEnd {
  let block = scanner.scan(untilTrue: { char in
    return (delimiters.contains(char) == false)
  })
  // Print:
  // "Never be satisfied " (first iteration)
  // "and always push yourself!" (second iteration)
  // "Do the things people say cannot be done" (third iteration)
  print("Block: \(block)")
	try scanner.skip() // push over the character
}
```

#### `public func scan(length: Int=1) -> String`
Read next length characters and accumulate it
If operation is succeded scanner's `position` are updated according to consumed scalars.
If fails an exception is thrown and `position` is not updated.

Example:
```swift
let scanner = StringScanner("Never be satisfied")
let partialString = scanner.scan(5) // "Never"
```
### `peek` functions

#### `public func peek(length: Int=1) -> String`

Peek functions are the same as concept of `scan()` but unless it it does not update internal scanner's `position` index.
These functions usually return only `starting index` of matched pattern.