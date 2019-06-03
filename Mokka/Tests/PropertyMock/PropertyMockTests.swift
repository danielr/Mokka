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

class PropertyMockTests: XCTestCase {
    
    var sut: PropertyMock<String>!
    
    override func setUp() {
        sut = PropertyMock<String>(name: "test")
    }
    
    func testNameIsSetFromInit() {
        XCTAssertEqual(sut.name, "test")
    }
    
    // MARK: Value
    
    func testGetReturnsValue() {
        sut.value = "foo"
        XCTAssertEqual(sut.get(), "foo")
    }

    func testSetStoresValue() {
        sut.set("foo")
        XCTAssertEqual(sut.value, "foo")
    }

    // MARK: Verification
    
    func testHasBeenReadIsFalseInitially() {
        XCTAssertFalse(sut.hasBeenRead)
    }

    func testHasBeenSetIsFalseInitially() {
        XCTAssertFalse(sut.hasBeenSet)
    }

    func testGettingTheValueRecordsRead() {
        sut.value = "foo"
        _ = sut.get()
        XCTAssertTrue(sut.hasBeenRead)
    }
    
    func testSettingTheValueRecordsWrite() {
        sut.set("foo")
        XCTAssertTrue(sut.hasBeenSet)
    }
    
    // MARK: Reset
    
    func testResetSetsValueToNil() {
        sut.value = "foo"
        sut.reset()
        XCTAssertNil(sut.value)
    }

    func testResetSetsHasBeenReadToFalse() {
        sut.value = "foo"
        _ = sut.get()
        sut.reset()
        XCTAssertFalse(sut.hasBeenRead)
    }

    func testResetSetsHasBeenSetToFalse() {
        sut.set("foo")
        sut.reset()
        XCTAssertFalse(sut.hasBeenSet)
    }
}
