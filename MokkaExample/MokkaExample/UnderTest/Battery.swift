//
//  Battery.swift
//  MokkaExample
//
//  Created by Daniel Rinser on 28.06.2019.
//  Copyright © 2019 Daniel Rinser. All rights reserved.
//

import Foundation

protocol Battery {
    var capacity: Double { get }         // kWh
    var currentLevel: Double { get }     // 0...1
}
