//
//  Car.swift
//  MokkaExample
//
//  Created by Daniel Rinser on 28.06.2019.
//  Copyright © 2019 Daniel Rinser. All rights reserved.
//

import Foundation

class Car {
    private let engine: Engine
    private let battery: Battery

    init(engine: Engine, battery: Battery) {
        self.engine = engine
        self.battery = battery
    }
    
    func turnOn() {
        engine.turnOn()
    }
    
    func setRadioVolume(to volume: Float) {
    }
    
    func accelerate() { // accelerate by 5 km/h
        let speed = engine.currentSpeed(in: .kilometersPerHour)
        let newSpeed = min(speed + 5.0, 180.0)
        if newSpeed > speed {
            engine.setSpeed(to: newSpeed)
        }
    }
    
    func calculateRemainingRange(in unit: UnitLength) -> Double {
        let averageConsumptionPerKilometer = 0.18 // kWh
        let availableEnergy = battery.capacity * battery.currentLevel
        let rangeInKilometers = availableEnergy / averageConsumptionPerKilometer
        let rangeInTargetUnit = Measurement(value: rangeInKilometers, unit: UnitLength.kilometers).converted(to: unit).value
        return rangeInTargetUnit
    }
    
    var currentSpeed: Int {
        return Int(engine.currentSpeed(in: .kilometersPerHour).rounded())
    }
}
