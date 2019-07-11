//
//  Engine.swift
//  MokkaExample
//
//  Created by Daniel Rinser on 28.06.2019.
//  Copyright © 2019 Daniel Rinser. All rights reserved.
//

import Foundation

enum EngineError: Error {
    case outOfGas
}

protocol Engine {
    func turnOn() throws
    func turnOff()
    var isOn: Bool { get }
    
    func setSpeed(to value: Float)  // kilometers per hour
    func setSpeed(to value: Float, in unit: UnitSpeed)
    
    func currentSpeed(in unit: UnitSpeed) -> Float
}
