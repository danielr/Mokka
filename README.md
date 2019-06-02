# ☕️ Mokka
A collection of helpers to make it easier to write testing mocks in Swift.

## Motivation
Due to Swift's very static nature, mocking and stubbing is much harder to do than in other languages. There is no dynamic mocking framework like `OCMock` or `Mockito`. The usual approach is to just write your mock objects manually, like so:

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

and for stubbing:

```swift
func testSomething() {
    // static stubbing
    myMock.doSomethingFunc.returns(100)

    // dynamic stubbing
    myMock.doSomethingFunc.returns { $0 + 200 }   // $0 is the argument(s) passed to the method

    // conditional stubbing
    myMock.doSomethingFunc.returns(123, when: { $0 == "foo" })
    myMock.doSomethingFunc.returns(456, when: { $0 == "bar" })
    myMock.doSomethingFunc.returns(789)
}
```

## Author

Mokka has been created and is maintained by Daniel Rinser, [@danielrinser](https://twitter.com/danielrinser).

## License

Mokka is available under the [MIT License](https://github.com/danielr/Mokka/blob/master/LICENSE).
