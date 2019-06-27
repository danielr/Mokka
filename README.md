# ☕️ Mokka

[![Bitrise build status](https://img.shields.io/bitrise/1b64319566421dbf/master.svg?token=aK7YocCEHyQlNQ9l43nE3g)](https://app.bitrise.io/app/1b64319566421dbf)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)
[![Twitter](https://img.shields.io/badge/twitter-@danielrinser-blue.svg)](http://twitter.com/danielrinser)

A collection of helpers to make it easier to write testing mocks in Swift.

## Motivation
Due to Swift's very static nature, mocking and stubbing is much harder to do than in other languages. There are no dynamic mocking framework like `OCMock` or `Mockito`. The usual approach is to just write your mock objects manually, like so:

```swift
protocol Foo {
    func doSomething(arg: String) -> Int
}

class FooMock: Foo {
    var doSomethingHasBeenCalled = false
    var doSomethingArgument = String?
    var doSomethingReturnValue: Int!

    func doSomething(arg: String) -> Int {
        doSomethingHasBeenCalled = true
        doSomethingArgument = arg
        return doSomethingReturnValue
    }
}
```

This is a lot of boilerplate (and this is just a simple example, which doesn't allow for conditional stubbing, for example). This is where Mokka comes in.


## Overview

Mokka provides a testing helper class called `FunctionMock<Args>` (and a variant for returning functions called `ReturningFunctionMock<Args, ReturnValue>`) that takes care of:

* Recording function/method calls for verification (*Has the method been called?*, *How often has the method been called?*)
* Capturing the arguments for verification (*With which arguments has the method been called?*)
* Stubbing return values (also conditionally) (*This method should return `42` if called with argument `"x"`*)

With these helpers it gets much more convenient to define your mock objects:

```swift
class FooMock: Foo {
    let doSomethingFunc = ReturningFunctionMock<String, Int>(name: "doSomething(arg:)")
    func doSomething(arg: String) -> Int {
        return doSomethingFunc.recordCallAndReturn(arg)
    }
}
```

You can now use the function mock object for verification:

```swift
func testSomething() {
    // ...
    XCTAssertEqual(myMock.doSomethingFunc.callCount, 2)
    XCTAssertEqual(myMock.doSomethingFunc.argument, "lorem ipsum")
    // ...
}
```

and for faking the return value:

```swift
func testSomething() {
    // static return value
    myMock.doSomethingFunc.returns(100)

    // dynamic return value
    myMock.doSomethingFunc.returns { $0 + 200 }   // $0 is the argument(s) passed to the method

    // conditional return value
    myMock.doSomethingFunc.returns(123, when: { $0 == "foo" })
    myMock.doSomethingFunc.returns(456, when: { $0 == "bar" })
    myMock.doSomethingFunc.returns(789)
}
```

## Requirements

* Xcode 10.2
* Swift 5.0

## Installation


## Documentation

### Types of mocks

There are currently three types of mock helpers available:

* **`FunctionMock`:** Allows to record the calls to a function (the call count and the arguments), as well as to optionally stub the function's behavior. Use this for functions that have a `Void` return value.
* **`ReturningFunctionMock`:** Provides the same functionality as `FunctionMock`, but adds the ability to fake the returned value. Use this for functions that have a non-void return value.
* **`PropertyMock`:** Allows to provide fake values for a property and record whether a property has been read or set.

### How to implement your mocks



### Call count verification

A common use case for mocks is to verify if a method has been called, and sometimes specifically how often it has been called. For that, both `FunctionMock` and `ReturningFunctionMock` provide some properties:

* `called: Bool` Returns whether the method has been called (once or more).
* `calledOnce: Bool` Returns whether the method has been called exactly once.
* `callCount: Int` The number of times the method has been called.

```swift
XCTAssertTrue(someMock.myFunction.called)
XCTAssertTrue(someMock.myFunction.calledOnce)
XCTAssertEqual(someMock.myFunction.callCount, 3)
```

### Argument verification

In addition to verifying if a function has been called, you often also want to check the argument(s) with which the function has been called. You can do that via the `arguments` property:

```
XCTAssertEqual(someMock.myFunction.arguments.foo, "value")
XCTAssertEqual(someMock.myFunction.arguments.bar, 42)
```

(This requires that you follow the recommended practice of naming the tuple members, see above.)


For single-argument functions you can also use the `argument` property, which looks a bit nicer:

```
XCTAssertEqual(someMock.myFunction.argument, "value")
```

### Stubbing

Sometimes it's necessary to stub the behavior of a function, for example to introduce some important side-effects. One common example for this is calling a delegate method. You can do that by providing a closure that will be executed when the function is called. The closure will be provided with the function arguments:

```swift
let delegate = FooDelegateMock()
someMock.myFunction.stub { arg in
	delegate.somethingHappened(with: arg)
}
```

### Faking the return value

For returning functions it's crucial to be able to fake the return value. Mokka provides 3 ways if doing that: Static return values, dynamic return values and conditional return values. Let's have a look at each of those:

#### Providing a static return value

For most cases it's sufficient to provide a simple static value that should be returned by the mock implementation:

```swift
deepThoughtMock.answerToEverythingFunc.returns(42)
```

#### Providing a return value dynamically

Sometimes it's convenient to provide a return value that depends in the functions arguments. You can do that by providing a closure: 

```swift
calculatorMock.addFunc.returns { args in
	return args.firstValue + args.secondValue
}
```

#### Providing return values conditionally

Both, static and dynamic return values can also be provided conditionally:

```swift
    myMock.doSomethingFunc.returns(123, when: { $0 == "foo" })
    myMock.doSomethingFunc.returns(456, when: { $0 == "bar" })
    myMock.doSomethingFunc.returns(789)	   // otherwise
}
```

### Mocking properties

In many cases it is enough to just implement any property requirements of the mocked protocol by declaring a stored property with a default value in your mock. However, when you want to be able to explicitly track whether a property has been read or written, Mokka's `PropertyMock` can be helpful.

This is how you declare create it in your mock implementation:

```swift
class SomeMock {
    let fooProperty = PropertyMock<Int>(name: "foo")
    var foo: Int {
        get { return fooProperty.get() }
        set { fooProperty.set(newValue) }
    }
}
```

Then you can use it in your tests like this:

```swift
someMock.fooProperty.value = 10

// do something

XCTAssertTrue(someMock.fooProperty.hasBeenRead)
XCTAssertFalse(someMock.fooProperty.hasBeenSet
```

Another nice touch is that you don't need to provide a default value for the property if you use `PropertyMock` (the `get()` method fails with a `preconditionFailure` if there is no value).

## Author

Mokka has been created and is maintained by Daniel Rinser, [@danielrinser](https://twitter.com/danielrinser).

## License

Mokka is available under the [MIT License](https://github.com/danielr/Mokka/blob/master/LICENSE).
