//
//  TestError.swift
//  Mokka
//
//  Created by Daniel Rinser on 10.07.2019.
//  Copyright © 2019 Daniel Rinser. All rights reserved.
//

import Foundation

enum TestError: Error {
    case errorOne
    case errorTwo
}

extension TestError: Equatable {}
