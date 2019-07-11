//
// Copyright (c) 2019 Daniel Rinser and contributors.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
// OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation

/// A `FunctionMock` allows to record the calls to a function (the call count and the
/// arguments), as well as to optionally stub the function's behavior.
///
/// Note: If you have a function that returns a value, you probably want to use
/// `ReturningFunctionMock` instead, which allows to stub the return value.
///
/// The function mock is generic over the function's arguments' types. The generic
/// parameter `Args` is usually a tuple of size n where n is the number of the
/// function's arguments.
///
/// For a function with this signature
///
///     func doSomething(arg1: String, arg2: [Int])
///
/// declare the function mock like this:
///
///     let doSomethingFunc = FunctionMock<(String, [Int])>(name: "doSomething(arg1:arg2:)")
///
public class FunctionMock<Args> {
    
    /// The name of the mocked function.
    public let name: String?
    
    /// The number of times the mocked function has been called.
    public private(set) var callCount: Int = 0
    
    /// Returns true, iff the mocked function has been called once or more.
    public var called: Bool {
        return callCount >= 1
    }

    /// Returns true, iff the mocked function has been called exactly once.
    public var calledOnce: Bool {
        return callCount == 1
    }

    /// The arguments of the *last* function call, or `nil` if the function has never been called.
    public private(set) var arguments: Args?
    
    /// The argument of the *last* function call, or `nil` if the function has never been called.
    public var argument: Args? { return arguments }    // syntactic alternative for single-arg methods

    private var stubBlock: ((Args) -> Void)?
    internal var error: Error?
    
    /// Creates a new instance of a function mock with the specified name.
    ///
    /// - parameters:
    ///     - name: (optional) The name of the function. Use the standard #selector() syntax.
    ///             This will only be used for informational purposes (e.g. by
    ///             matchers or in error messages).
    public init(name: String? = nil) {
        self.name = name
    }
    
    /// Provide a closure that will be executed when the function is called.
    /// The closure will be provided with the function arguments.
    ///
    /// - parameters:
    ///     - fn: A function to execute whenever the mocked function is called.
    ///     - args: The original arguments that the mocked function has been called with.
    public func stub(_ fn: @escaping (_ args: Args) -> Void) {
        stubBlock = fn
    }
    
    /// Record a call of the mocked function.
    ///
    /// - parameters:
    ///     - args: The arguments that the mocked function has been called with.
    public func recordCall(_ args: Args) {
        callCount += 1
        arguments = args
        stubBlock?(args)
    }
    
    /// Record a call of the mocked function and potentially throw an error, if configured.
    ///
    /// - parameters:
    ///     - args: The arguments that the mocked function has been called with.
    /// - throws: The error that has been configured via `throws(_:)`, if any.
    public func recordCallAndThrow(_ args: Args) throws {
        recordCall(args)
        if let error = error {
            throw error
        }
    }
    
    /// Configure an error to be thrown by the mocked function.
    public func `throws`(_ error: Error) {
        self.error = error
    }

    /// Reset the mock to its initial state. This will set the call count to 0 and
    /// remove any recorded arguments.
    public func reset() {
        callCount = 0
        arguments = nil
        error = nil
    }
}

extension FunctionMock where Args == Void {
    
    /// Record a call of the mocked function without arguments.
    public func recordCall() {
        // special handling of functions without arguments to make the call-site less weird due to Void generic type
        recordCall(())
    }
    
    /// Record a call of the mocked function without arguments and potentially throw an error, if configured.
    public func recordCallAndThrow() throws {
        try recordCallAndThrow(())
    }
}
