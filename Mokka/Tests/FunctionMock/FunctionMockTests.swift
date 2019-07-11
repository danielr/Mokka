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

import XCTest
@testable import Mokka

class FunctionMockTests: XCTestCase {

    var sut: FunctionMock<String>!
    
    override func setUp() {
        sut = FunctionMock<String>(name: "test(foo:)")
    }

    func testNameIsSetFromInit() {
        XCTAssertEqual(sut.name, "test(foo:)")
    }
    
    // MARK: Call count
    
    func testCallCountIsZeroInitially() {
        XCTAssertEqual(sut.callCount, 0)
    }
    
    func testCalledReturnsFalseInitially() {
        XCTAssertEqual(sut.called, false)
    }
    
    func testCalledOnceReturnsFalseInitially() {
        XCTAssertEqual(sut.calledOnce, false)
    }
    
    func testCallCountIsOneAfterCallingOnce() {
        sut.recordCall("foo")
        XCTAssertEqual(sut.callCount, 1)
    }
    
    func testCalledReturnsTrueAfterCallingOnce() {
        sut.recordCall("foo")
        XCTAssertEqual(sut.called, true)
    }
    
    func testCalledOnceReturnsTrueAfterCallingOnce() {
        sut.recordCall("foo")
        XCTAssertEqual(sut.calledOnce, true)
    }

    func testCallCountIsTwoAfterCallingTwice() {
        sut.recordCall("foo")
        sut.recordCall("bar")
        XCTAssertEqual(sut.callCount, 2)
    }
    
    func testCalledReturnsTrueAfterCallingTwice() {
        sut.recordCall("foo")
        sut.recordCall("bar")
        XCTAssertEqual(sut.called, true)
    }
    
    func testCalledOnceReturnsFalseAfterCallingTwice() {
        sut.recordCall("foo")
        sut.recordCall("bar")
        XCTAssertEqual(sut.calledOnce, false)
    }
    
    // MARK: Argument capturing
    
    func testArgumentIsNilWhenNotCalled() {
        XCTAssertNil(sut.argument)
    }

    func testArgumentsIsNilWhenNotCalled() {
        XCTAssertNil(sut.arguments)
    }

    func testArgumentIsSetToArgumentAfterCalling() {
        sut.recordCall("foo")
        XCTAssertEqual(sut.argument, "foo")
    }
    
    func testArgumentsIsSetToArgumentAfterCalling() {
        sut.recordCall("foo")
        XCTAssertEqual(sut.arguments, "foo")
    }

    func testArgumentIsSetToLastArgumentAfterCallingTwice() {
        sut.recordCall("foo")
        sut.recordCall("bar")
        XCTAssertEqual(sut.argument, "bar")
    }
    
    func testArgumentsIsSetToLastArgumentAfterCallingTwice() {
        sut.recordCall("foo")
        sut.recordCall("bar")
        XCTAssertEqual(sut.arguments, "bar")
    }

    // MARK: Stubbing
    
    func testStubBodyIsCalledWithCorrectArgument() {
        let callExpectation = expectation(description: "Stub body executed")
        sut.stub { (arg) in
            callExpectation.fulfill()
            XCTAssertEqual(arg, "foo")
        }
        
        sut.recordCall("foo")
        
        waitForExpectations(timeout: 0.0, handler: nil)
    }
    
    // MARK: Throwing
    
    func testDoesNotThrowErrorIfNotExplicitlyConfigured() {
        XCTAssertNoThrow(try sut.recordCallAndThrow("foo"))
    }
    
    func testThrowsErrorAfterSettingError() {
        sut.throws(TestError.errorOne)
        XCTAssertThrowsError(try sut.recordCallAndThrow("foo")) { error in
            XCTAssert(error is TestError, "Unexpected error type thrown")
            XCTAssertEqual(error as! TestError, TestError.errorOne)
        }
    }

    func testRecordCallAndThrowRecordsCalls() {
        XCTAssertNoThrow(try sut.recordCallAndThrow("foo"))
        XCTAssertNoThrow(try sut.recordCallAndThrow("bar"))
        XCTAssertEqual(sut.callCount, 2)
    }

    func testRecordCallAndThrowCapturesArguments() {
        XCTAssertNoThrow(try sut.recordCallAndThrow("foo"))
        XCTAssertEqual(sut.argument, "foo")
    }
    
    // MARK: Reset
    
    func testCallCountIsZeroAfterReset() {
        sut.recordCall("foo")
        sut.reset()
        XCTAssertEqual(sut.callCount, 0)
    }
    
    func testCalledReturnsFalseAfterReset() {
        sut.recordCall("foo")
        sut.reset()
        XCTAssertEqual(sut.called, false)
    }
    
    func testCalledOnceReturnsFalseAfterReset() {
        sut.recordCall("foo")
        sut.reset()
        XCTAssertEqual(sut.calledOnce, false)
    }

    func testResetSetsArgumentToNil() {
        sut.recordCall("foo")
        sut.reset()
        XCTAssertNil(sut.argument)
    }
    
    func testResetSetsErrorToNil() {
        sut.throws(TestError.errorOne)
        sut.reset()
        XCTAssertNoThrow(try sut.recordCallAndThrow("foo"))
    }
    
    // MARK: Misc
    
    func testNoArgumentRecordCallOverloadRecordsCall() {
        let sut = FunctionMock<Void>(name: "test()")
        sut.recordCall()
        XCTAssertEqual(sut.callCount, 1)
    }

    func testNoArgumentRecordCallAndThrowOverloadRecordsCall() {
        let sut = FunctionMock<Void>(name: "test()")
        XCTAssertNoThrow(try sut.recordCallAndThrow())
        XCTAssertEqual(sut.callCount, 1)
    }
}
