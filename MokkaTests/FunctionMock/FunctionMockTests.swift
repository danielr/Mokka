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
    
    // MARK: Stubbing
    
    // MARK: Reset
    
}
