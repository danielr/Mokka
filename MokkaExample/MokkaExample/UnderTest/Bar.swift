//
//  Bar.swift
//  MokkaExample
//
//  Created by Daniel Rinser on 01.06.2019.
//  Copyright © 2019 Daniel Rinser. All rights reserved.
//

import Foundation

class Bar {
    let foo: Foo
    
    init(foo: Foo) {
        self.foo = foo
    }
    
    func doSomethingWithFoo() -> Int {
        let value = foo.doSomething(arg: "abc")
        let multiplier = foo.baz
        return value * multiplier
    }
}
