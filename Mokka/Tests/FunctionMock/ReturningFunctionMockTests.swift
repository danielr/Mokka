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

class ReturningFunctionMockTests: XCTestCase {
    
    var sut: ReturningFunctionMock<String, Int>!
    
    override func setUp() {
        sut = ReturningFunctionMock<String, Int>(name: "test(foo:)")
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
        sut.returns(42)
        _ = sut.recordCallAndReturn("foo")
        XCTAssertEqual(sut.callCount, 1)
    }
    
    func testCalledReturnsTrueAfterCallingOnce() {
        sut.returns(42)
        _ = sut.recordCallAndReturn("foo")
        XCTAssertEqual(sut.called, true)
    }
    
    func testCalledOnceReturnsTrueAfterCallingOnce() {
        sut.returns(42)
        _ = sut.recordCallAndReturn("foo")
        XCTAssertEqual(sut.calledOnce, true)
    }
    
    func testCallCountIsTwoAfterCallingTwice() {
        sut.returns(42)
        _ = sut.recordCallAndReturn("foo")
        _ = sut.recordCallAndReturn("bar")
        XCTAssertEqual(sut.callCount, 2)
    }
    
    func testCalledReturnsTrueAfterCallingTwice() {
        sut.returns(42)
        _ = sut.recordCallAndReturn("foo")
        _ = sut.recordCallAndReturn("bar")
        XCTAssertEqual(sut.called, true)
    }
    
    func testCalledOnceReturnsFalseAfterCallingTwice() {
        sut.returns(42)
        _ = sut.recordCallAndReturn("foo")
        _ = sut.recordCallAndReturn("bar")
        XCTAssertEqual(sut.calledOnce, false)
    }
    
    // MARK: - Stubbing
    
    func testReturnsDefaultReturnValueIfNoExplicitStubsRegistered() {
        sut.defaultReturnValue = 42
        let result = sut.recordCallAndReturn("foo")
        XCTAssertEqual(result, 42)
    }

    func testReturnsStaticallySubbedReturnValue() {
        sut.returns(42)
        let result = sut.recordCallAndReturn("foo")
        XCTAssertEqual(result, 42)
    }

    func testReturnsDynamicallySubbedReturnValue() {
        sut.returns { arg in
            return arg == "foo" ? 42 : 66
        }
        XCTAssertEqual(sut.recordCallAndReturn("foo"), 42)
        XCTAssertEqual(sut.recordCallAndReturn("bar"), 66)
    }
    
    func testReturnsFirstStubbedReturnValueIfMultipleMatch() {
        sut.returns(42)
        sut.returns(66)
        let result = sut.recordCallAndReturn("foo")
        XCTAssertEqual(result, 42)
    }
    
    // MARK: - Conditional stubbing
    
    func testReturnsDefaultReturnValueIfConditionNotMet() {
        sut.defaultReturnValue = 42
        sut.returns(66, when: { $0 == "foo" })
        let result = sut.recordCallAndReturn("bar")
        XCTAssertEqual(result, 42)
    }

    func testReturnsStaticStubbedReturnValueIfConditionMet() {
        sut.defaultReturnValue = 42
        sut.returns(66, when: { $0 == "foo" })
        let result = sut.recordCallAndReturn("foo")
        XCTAssertEqual(result, 66)
    }

    func testReturnsDynamicStubbedReturnValueIfConditionMet() {
        sut.defaultReturnValue = 42
        sut.returns({ arg in return 10 + 32 }, when: { $0 == "foo" })
        let result = sut.recordCallAndReturn("foo")
        XCTAssertEqual(result, 42)
    }

    func testReturnsSecondStubbedValueIfConditionOfFirstStubNotMet() {
        sut.returns(66, when: { $0 == "foo" })
        sut.returns(42, when: { $0 == "bar" })
        let result = sut.recordCallAndReturn("bar")
        XCTAssertEqual(result, 42)
    }

    // MARK: Throwing
    
    func testDoesNotThrowErrorIfNotExplicitlyConfigured() {
        sut.returns(42)
        XCTAssertNoThrow(try sut.recordCallAndReturnOrThrow("foo"))
    }
    
    func testThrowsErrorAfterSettingError() {
        sut.throws(TestError.errorOne)
        XCTAssertThrowsError(try sut.recordCallAndReturnOrThrow("foo")) { error in
            XCTAssert(error is TestError, "Unexpected error type thrown")
            XCTAssertEqual(error as! TestError, TestError.errorOne)
        }
    }
    
    func testRecordCallAndReturnOrThrowRecordsCallsWhenNotThrowing() {
        sut.returns(42)
        XCTAssertNoThrow(try sut.recordCallAndReturnOrThrow("foo"))
        XCTAssertNoThrow(try sut.recordCallAndReturnOrThrow("bar"))
        XCTAssertEqual(sut.callCount, 2)
    }
    
    func testRecordCallAndReturnOrThrowCapturesArgumentsWhenNotThrowing() {
        sut.returns(42)
        XCTAssertNoThrow(try sut.recordCallAndReturnOrThrow("foo"))
        XCTAssertEqual(sut.argument, "foo")
    }

    func testRecordCallAndReturnOrThrowRecordsCallsWhenThrowing() {
        sut.throws(TestError.errorOne)
        XCTAssertThrowsError(try sut.recordCallAndReturnOrThrow("foo"))
        XCTAssertThrowsError(try sut.recordCallAndReturnOrThrow("bar"))
        XCTAssertEqual(sut.callCount, 2)
    }
    
    func testRecordCallAndReturnOrThrowCapturesArgumentsWhenThrowing() {
        sut.throws(TestError.errorOne)
        XCTAssertThrowsError(try sut.recordCallAndReturnOrThrow("foo"))
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
    
    func testResetRemovesDefaultReturnValue() {
        sut.defaultReturnValue = 42
        sut.reset()
        XCTAssertNil(sut.defaultReturnValue)
    }

    func testResetRemovesStaticStubbedReturnValue() {
        sut.returns(42)
        sut.reset()
        sut.defaultReturnValue = 0
        XCTAssertEqual(sut.recordCallAndReturn("foo"), 0)
    }

    func testResetRemovesDynamicStubbedReturnValue() {
        sut.returns { arg in 10 + 20 }
        sut.reset()
        sut.defaultReturnValue = 0
        XCTAssertEqual(sut.recordCallAndReturn("foo"), 0)
    }
    
    func testResetSetsErrorToNil() {
        sut.throws(TestError.errorOne)
        sut.reset()
        XCTAssertNoThrow(try sut.recordCallAndReturnOrThrow("foo"))
    }
}
