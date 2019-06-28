//
//  EngineMock.swift
//  MokkaExampleTests
//
//  Created by Daniel Rinser on 28.06.2019.
//  Copyright © 2019 Daniel Rinser. All rights reserved.
//

import XCTest
import Mokka
@testable import MokkaExample

class EngineMock: Engine {
    let turnOnFunc = FunctionMock<Void>(name: "turnOn()")
    func turnOn() {
        turnOnFunc.recordCall()
    }
    
    let turnOffFunc = FunctionMock<Void>(name: "turnOff()")
    func turnOff() {
        turnOffFunc.recordCall()
    }
    
    let isOnProperty = PropertyMock<Bool>(name: "isOn")
    var isOn: Bool {
        get { return isOnProperty.get() }
        set { isOnProperty.set(newValue) }
    }
    
    let setSpeedFunc = FunctionMock<Float>(name: "setSpeed(to:)")
    func setSpeed(to value: Float) {
        setSpeedFunc.recordCall(value)
    }
    
    let setSpeedInUnitFunc = FunctionMock<(value: Float, unit: UnitSpeed)>(name: "setSpeed(to:unit:)")
    func setSpeed(to value: Float, in unit: UnitSpeed) {
        setSpeedInUnitFunc.recordCall((value: value, unit: unit))
    }
    
    let currentSpeedFunc = ReturningFunctionMock<UnitSpeed, Float>(name: "currentSpeed(in:)")
    func currentSpeed(in unit: UnitSpeed) -> Float {
        return currentSpeedFunc.recordCallAndReturn(unit)
    }
}
