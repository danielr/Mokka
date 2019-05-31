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

public class FunctionMock<Args> {
    
    public let name: String
    
    public private(set) var callCount: Int = 0
    
    public var called: Bool {
        return callCount >= 1
    }

    public var calledOnce: Bool {
        return callCount == 1
    }

    public private(set) var arguments: Args?
    public var argument: Args? { return arguments }    // syntactic alternative for single-arg methods
    
    public init(name: String) {
        self.name = name
    }
    
    private var stubBlock: ((Args) -> Void)?
    
    public func stub(_ block: @escaping (Args) -> Void) {
        stubBlock = block
    }
    
    public func recordCall(_ args: Args) {
        // record call and capture argumanets
        callCount += 1
        arguments = args
        
        // call
        stubBlock?(args)
    }
    
    public func reset() {
        callCount = 0
        arguments = nil
    }
}

// special handling of functions without arguments to make the call-site less weird due to Void generic type
extension FunctionMock where Args == Void {
    public func recordCall() {
        recordCall(())
    }
}
