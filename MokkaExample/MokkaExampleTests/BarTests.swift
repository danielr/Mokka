//
//  BarTests.swift
//  MokkaExampleTests
//
//  Created by Daniel Rinser on 01.06.2019.
//  Copyright © 2019 Daniel Rinser. All rights reserved.
//

import XCTest
@testable import MokkaExample

class BarTests: XCTestCase {

    var fooMock: FooMock!
    var sut: Bar!
    
    override func setUp() {
        fooMock = FooMock()
        sut = Bar(foo: fooMock)
    }

    func testExample() {
        fooMock.doSomethingFunc.returns(42)
        let result = sut.doSomethingWithFoo()
        XCTAssertEqual(result, 126)
    }
}
