//
//  FooMock.swift
//  MokkaExampleTests
//
//  Created by Daniel Rinser on 01.06.2019.
//  Copyright © 2019 Daniel Rinser. All rights reserved.
//

import XCTest
import Mokka
@testable import MokkaExample

class FooMock: Foo {

    let bazProperty = PropertyMock<Int>(name: "baz")
    var baz: Int {
        get { return bazProperty.get() }
        set { bazProperty.set(newValue) }
    }

    let readonlyBazProperty = PropertyMock<String>(name: "readonlyBaz")
    var readonlyBaz: String {
        get { return readonlyBazProperty.get() }
    }

    
    let doSomethingFunc = ReturningFunctionMock<String, Int>(name: "doSomething(arg:)")
    func doSomething(arg: String) -> Int {
        return doSomethingFunc.recordCallAndReturn(arg)
    }
}
