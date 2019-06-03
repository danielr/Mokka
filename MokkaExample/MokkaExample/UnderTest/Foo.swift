//
//  Foo.swift
//  MokkaExample
//
//  Created by Daniel Rinser on 01.06.2019.
//  Copyright © 2019 Daniel Rinser. All rights reserved.
//

import Foundation

protocol Foo {
    var baz: Int { get set }
    var readonlyBaz: String { get }
    
    func doSomething(arg: String) -> Int
}
