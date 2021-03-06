<p align="center">
    <img src="Mokka_logo.png" width="600” max-width="90%" alt="Mokka" />
</p>

<p align="center">
	<a href="https://app.bitrise.io/app/1b64319566421dbf"><img src="https://img.shields.io/bitrise/1b64319566421dbf/master.svg?token=aK7YocCEHyQlNQ9l43nE3g" alt="Bitrise build status" /></a>
	<a href="https://codecov.io/gh/danielr/Mokka"><img src="https://img.shields.io/codecov/c/github/danielr/Mokka.svg" alt="Code coverage" /></a>
	<a href="https://cocoapods.org/pods/Mokka"><img src="https://img.shields.io/cocoapods/v/Mokka.svg" alt="CocoaPods" /></a>
	<img src="https://img.shields.io/badge/swift-5.0-DE5C43.svg" alt="Swift Version" />
	<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-lightgrey.svg" alt="License" /></a>
	<a href="http://twitter.com/danielrinser"><img src="https://img.shields.io/badge/twitter-@danielrinser-blue.svg" alt="Twitter" /></a>
</p>

<h3 align="center">
	A collection of helpers to make it easier to write testing mocks in Swift.
</h3>


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
    let doSomethingFunc = ReturningFunctionMock<String, Int>()
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

### CocoaPods

To install Mokka via CocoaPods, just add the `Mokka` pod for your **test target** to the Podfile:

```ruby
pod 'Mokka'
```

### Swift Package Manager

You can install Mokka using Swift Package Manager. Just add this repository as a dependency to your `Package.swift` file (and don't forget to also add `"Mokka"` as a dependency in your test target):

```swift
dependencies: [
    .package(url: "https://github.com/danielr/Mokka", from: "1.0.0")
    // ...
]
```

### Carthage

To install Mokka with Carthage, add this to your Cartfile:

```
github "danielr/Mokka"
```

Then drag the built `Mokka.framework` to your project and make sure it's [added to the unit test target](https://github.com/Carthage/Carthage#adding-frameworks-to-unit-tests-or-a-framework), not the main app target. If you see issues errors like "The bundle xxx couldn’t be loaded because it is damaged or missing necessary resources.", then you [might need to tweak your test target's **Runtime Search Paths**](https://github.com/Carthage/Carthage/issues/1002).

## Documentation

### Types of mocks

There are currently three types of mock helpers available:

* **`FunctionMock`:** Allows to record the calls to a function (the call count and the arguments), as well as to optionally stub the function's behavior. Use this for functions that have a `Void` return value.
* **`ReturningFunctionMock`:** Provides the same functionality as `FunctionMock`, but adds the ability to fake the returned value. Use this for functions that have a non-void return value.
* **`PropertyMock`:** Allows to provide fake values for a property and record whether a property has been read or set.

### How to implement your mocks

The first step is to implement your mocks using Mokka's helpers.
The general approach is the same for all types of mocks: You declare a property for the mock and use that mock object inside your function implementations to record the calls to that function.

For the examples below, let's assume we want to mock the following protocol:

```swift
protocol Engine {
    func turnOn()
    func turnOff()
    var isOn: Bool { get }

    func setSpeed(to value: Float)  // kilometers per hour
    func setSpeed(to value: Float, in unit: UnitSpeed)

    func currentSpeed(in unit: UnitSpeed) -> Double
}
```

#### Functions without return value

For functions that don't return a value, use `FunctionMock<Args>`. This class has one generic parameter which defines the type(s) of the argument(s).

For functions with **no arguments**, that should be `Void`:

```swift
class EngineMock: Engine {
    let turnOnFunc = FunctionMock<Void>(name: "turnOn()")
    func turnOn() {
        turnOnFunc.recordCall()
    }
	
    // ...
}
```

*Note: The `name` parameter in the mock initializers is optional. It is purely informational and might be useful for error messages (e.g. better assertion error messages). It is good practice to provide the names in the standard Swift #selector syntax.*

For functions with a **single argument**, just use that argument's type:

```swift
class EngineMock: Engine {
    let setSpeedFunc = FunctionMock<Float>(name: "setSpeed(to:)")
    func setSpeed(to value: Float) {
        setSpeedFunc.recordCall(value)
    }
	
    // ...
}
```

For functions with **more than one argument**, you need to use a tuple to represent the arguments (because Swift does not ([yet?](https://github.com/apple/swift/blob/master/docs/GenericsManifesto.md#variadic-generics)) support variadic generic parameters). Although you don't have to, it is a good practice to name the tuple elements, which makes it much clearer when referring to them in your testing code.

```swift
class EngineMock: Engine {
    let setSpeedInUnitFunc = FunctionMock<(value: Float, unit: UnitSpeed)>(name: "setSpeed(to:unit:)")
    func setSpeed(to value: Float, in unit: UnitSpeed) {
        setSpeedInUnitFunc.recordCall((value: value, unit: unit))
    }
	
    // ...
}
```


#### Functions with return value

For functions with a return value, use `ReturningFunctionMock<Args, ReturnValue>`. This works very much the same way as `FunctionMock`, but adds a second generic parameter for the return value type. It also provides a `recordCallAndReturn()` method, instead of the `recordCall()` method.

```swift
class EngineMock: Engine {
    let currentSpeedFunc = ReturningFunctionMock<UnitSpeed, Double>(name: "currentSpeed(in:)")
    func currentSpeed(in unit: UnitSpeed) -> Double {
        return currentSpeedFunc.recordCallAndReturn(unit)
    }
	
    // ...
}
```

For the arguments of returning methods, the same rules apply as for non-returning functions (see above). For example:

* A mock for a function that has no arguments and returns a Bool would be declared as `ReturningFunctionMock<Void, Bool>`
* A mock for a function that has two arguments of type `Int` and `String?` and returns a `Double` would be declared as `ReturningFunctionMock<(arg1: Int, arg2: String?), Double>`


#### Properties

In many cases it is enough to just implement property requirements of the mocked protocol by declaring a stored property with a default value in your mock. However, when you want to be able to explicitly track whether a property has been read or written, Mokka's `PropertyMock` can be helpful. It is generic over the type of the property and its use in the mock implementation is quite self-explanatory: Instead of using a stored property, declare a computed property and delegate the getter and setter (if it's settable property) to the `get()` and `set(_:)` methods of the `PropertyMock` object:

```swift
class EngineMock: Engine {
    let isOnProperty = PropertyMock<Bool>(name: "isOn")
    var isOn: Bool {
        get { return isOnProperty.get() }
        set { isOnProperty.set(newValue) }
    }
	
    // ...
}
```

Note that you don't need to provide a default value for the property (the `get()` method fails with a `preconditionFailure` if there is no value).


### Call count verification

A common use case for mocks is to verify if a method has been called, and sometimes specifically how often it has been called. For that, both `FunctionMock` and `ReturningFunctionMock` provide some properties:

* `called: Bool` Returns whether the method has been called (once or more).
* `calledOnce: Bool` Returns whether the method has been called exactly once.
* `callCount: Int` The number of times the method has been called.

```swift
XCTAssertTrue(engineMock.setSpeedFunc.called)
XCTAssertTrue(engineMock.setSpeedFunc.calledOnce)
XCTAssertEqual(engineMock.setSpeedFunc.callCount, 3)
```

### Argument verification

In addition to verifying if a function has been called, you often also want to check the argument(s) with which the function has been called. You can do that via the `arguments` property:

```swift
XCTAssertEqual(engineMock.setSpeedInUnitFunc.arguments.value, 100.0)
XCTAssertEqual(engineMock.setSpeedInUnitFunc.arguments.unit, .kilometersPerHour)
```

(This requires that you follow the recommended practice of naming the tuple members, see above. If you don't, you have to access the arguments by their index, e.g. `arguments.0`.)


For single-argument functions (where there's no arguments tuple) you can also use the `argument` property, which looks a bit nicer:

```swift
XCTAssertEqual(engineMock.setSpeedFunc.argument, 100.0)
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

For returning functions it's crucial to be able to fake the return value. Mokka provides 3 ways of doing that: Static return values, dynamic return values and conditional return values. Let's have a look at each of those.

#### Providing a static return value

For most cases it's sufficient to provide a simple static value that should be returned by the mock implementation:

```swift
engineMock.currentSpeedFunc.returns(100.0)
```

#### Providing a return value dynamically

Sometimes it's convenient to provide a return value that is dynamically generated, often depending on the function's arguments. You can do that by providing a closure: 

```swift
engineMock.currentSpeedFunc.returns { unit in
    // always return 100 km/h, converted to the requested target unit
    let kmhValue = Measurement(value: 100, unit: UnitSpeed.kilometersPerHour)
    return kmhValue.converted(to: unit).value
}
```

#### Providing return values conditionally

Both, static and dynamic return values can also be provided conditionally:

```swift
engineMock.currentSpeedFunc.returns(100.00, when: { $0 == .kilometersPerHour })
engineMock.currentSpeedFunc.returns(62.137, when: { $0 == .milesPerHour })
engineMock.currentSpeedFunc.returns(0)	   // otherwise
```

### Mocking properties

This is how you use properties that are backed by `PropertyMock` in your testing code:

```swift
someMock.fooProperty.value = 10	// use value to access the underlying property value

// do something

XCTAssertTrue(someMock.fooProperty.hasBeenRead)
XCTAssertFalse(someMock.fooProperty.hasBeenSet
```

## Example

You can find a simple example project in [MokkaExample](MokkaExample/).

It includes

* a subject under test (`Car`)
* two mocked protocols (`Engine` and `Battery`)

It is a minimal example, but it should be enough to get you started with the concepts of Mokka.

## Author

Mokka has been created and is maintained by Daniel Rinser, [@danielrinser](https://twitter.com/danielrinser).

## License

Mokka is available under the [MIT License](https://github.com/danielr/Mokka/blob/master/LICENSE).
