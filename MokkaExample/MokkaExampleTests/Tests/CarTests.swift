//
//  CarTests.swift
//  MokkaExampleTests
//
//  Created by Daniel Rinser on 28.06.2019.
//  Copyright © 2019 Daniel Rinser. All rights reserved.
//

import XCTest
@testable import MokkaExample

class CarTests: XCTestCase {
    
    var engineMock: EngineMock!
    var batteryMock: BatteryMock!
    var car: Car!
    
    override func setUp() {
        engineMock = EngineMock()
        batteryMock = BatteryMock()
        car = Car(engine: engineMock, battery: batteryMock)
    }
    
    // MARK: - Starting the car
    
    func testTurningOnTheCarTurnsOnTheEngine() {
        car.turnOn()
        XCTAssertTrue(engineMock.turnOnFunc.called)
    }
    
    // MARK: - Acceleration
    
    func testAccelerateIncreasesEngineSpeedBy5KilometersPerHour() {
        engineMock.currentSpeedFunc.returns(50)
    
        car.accelerate()
        
        XCTAssertTrue(engineMock.setSpeedFunc.called)
        XCTAssertEqual(engineMock.setSpeedFunc.argument, 55)
    }

    func testAccelerateIncreasesEngineSpeedBy10KilometersPerHourIfCalledTwice() {
        // Since accelerate() relies on the engine's current speed and we call it multiple times now,
        // we need to make the engine's speed behave realistically. That can be easily done with
        // dynamic stubbing. Note that we can even introduce state via local variables that are used
        // in the stubbing closures.
        var currentSpeed: Float = 50
        engineMock.currentSpeedFunc.returns { _ in currentSpeed }
        engineMock.setSpeedFunc.stub { currentSpeed = $0 }
        
        car.accelerate()
        car.accelerate()

        XCTAssertTrue(engineMock.setSpeedFunc.called)
        XCTAssertEqual(engineMock.setSpeedFunc.argument, 60)
    }
    
    func testAccelerateDoesNotIncreasesEngineSpeedIfAlreadyAtMaxSpeed() {
        engineMock.currentSpeedFunc.returns(180)
        
        car.accelerate()
        
        XCTAssertFalse(engineMock.setSpeedFunc.called)
    }

    // MARK: - Range
    
    func testRangeIsCalculatedCorrectlyForLargeBatteryInKilometers() {
        batteryMock.capacityProperty.value = 90.0
        batteryMock.currentLevelProperty.value = 0.5
        
        let result = car.calculateRemainingRange(in: .kilometers)
        
        XCTAssertEqual(result, 250)
    }

    func testRangeIsCalculatedCorrectlyForSmallBatteryInMiles() {
        batteryMock.capacityProperty.value = 40.0
        batteryMock.currentLevelProperty.value = 0.3
        
        let result = car.calculateRemainingRange(in: .miles)
        
        XCTAssertEqual(result, 41.42, accuracy: 0.01)
    }
}
