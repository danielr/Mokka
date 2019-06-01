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

/// A `ReturningFunctionMock` allows to record the calls to a retuning function, but in
/// addition to a `FunctionMock` it also allows to statically or dynamically stub the return
/// value of the function.
///
/// The returning function mock is generic over the function's arguments' types and its
/// return value. The generic parameter `Args` is usually a tuple of size n where n is the
/// number of the function's arguments.
///
/// For a function with this signature
///
///     func doSomething(arg1: String, arg2: [Int]) -> Int
///
/// declare the function mock like this:
///
///     let doSomethingFunc = ReturningFunctionMock<(String, [Int]), Int>(name: "doSomething(arg1:arg2:)")
///
public class ReturningFunctionMock<Args, ReturnValue>: FunctionMock<Args> {
    
    private var stubs: [FunctionStub<Args, ReturnValue>] = []
    
    /// A return value that is used as a default.
    public var defaultReturnValue: ReturnValue?
    
    /// Reset the mock to its initial state. This will set the call count to 0,
    /// remove any recorded arguments and remove any stubs.
    public override func reset() {
        super.reset()
        
        defaultReturnValue = nil
        stubs.removeAll()
    }
    
    // MARK: - Call
    
    /// Record a call of the mocked function and return a stubbed return value.
    ///
    /// - parameters:
    ///     - args: The arguments that the mocked function has been called with.
    public func recordCallAndReturn(_ args: Args) -> ReturnValue {
        recordCall(args)
        
        // stub return value
        guard let stub = stubs.first(where: { $0.shouldHandle(args) }) else {
            if let returnValue = defaultReturnValue {
                return returnValue
            }
            preconditionFailure("No return value for \(name)")
        }
        
        return stub.handle(args)
    }
    
    // MARK: - Stubbing
    
    /// Stub a static return value that is used by `recordCallAndReturn(_:)`, with an
    /// optional condition closure.
    ///
    /// - parameters:
    ///     - returnValue: The return value to use.
    ///     - condition: An optional closure that is used to select whether this return value
    ///                  should be used. If the closure returns `true`, the return value will
    ///                  be used; if it returns `false`, it will be skipped. If the
    ///                  condition closure is `nil`, the return value will always be used.
    public func returns(_ returnValue: ReturnValue, when condition: ((Args) -> Bool)? = nil) {
        let stub = FunctionStub<Args, ReturnValue>(returnValue: returnValue, condition: condition)
        stubs.append(stub)
    }

    /// Stub a dynamic return value that is used by `recordCallAndReturn(_:)`.
    ///
    /// - parameters:
    ///     - handler:   A closure that returns the value to be used as return value.
    ///     - args:      The arguments of the original call to the mocked function.
    public func returns(_ handler: @escaping (_ args: Args) -> ReturnValue) {
        returns(handler, when: nil)
    }

    /// Stub a dynamic return value that is used by `recordCallAndReturn(_:)`, with an
    /// optional condition closure.
    ///
    /// - parameters:
    ///     - handler:   A closure that returns the value to be used as return value.
    ///     - args:      The arguments of the original call to the mocked function.
    ///     - condition: An optional closure that is used to select whether this return value
    ///                  should be used. If the closure returns `true`, the return value will
    ///                  be used; if it returns `false`, it will be skipped. If the
    ///                  condition closure is `nil`, the return value will always be used.
    public func returns(_ handler: @escaping (_ args: Args) -> ReturnValue, when condition: ((Args) -> Bool)? = nil) {
        let stub = FunctionStub<Args, ReturnValue>(handler: handler, condition: condition)
        stubs.append(stub)
    }
    
    // MARK: - FunctionStub
    
    /// Used internally to represent a static or dynamic stubbed return
    /// value with an optional condition.
    private class FunctionStub<Args, ReturnValue> {
        
        private enum Mode {
            case staticReturnValue(ReturnValue) // returns(42)
            case handler((Args) -> ReturnValue) // returns { return $0 / 2 }
        }
        
        private let condition: ((Args) -> Bool)?
        private let mode: Mode
        
        init(returnValue: ReturnValue, condition: ((Args) -> Bool)?) {
            self.mode = .staticReturnValue(returnValue)
            self.condition = condition
        }
        
        init(handler: @escaping (Args) -> ReturnValue, condition: ((Args) -> Bool)?) {
            self.mode = .handler(handler)
            self.condition = condition
        }
        
        func shouldHandle(_ args: Args) -> Bool {
            guard let condition = self.condition else { return true }
            return condition(args)
        }
        
        func handle(_ args: Args) -> ReturnValue {
            switch self.mode {
            case .staticReturnValue(let returnValue):
                return returnValue
            case .handler(let handler):
                return handler(args)
            }
        }
    }
}
