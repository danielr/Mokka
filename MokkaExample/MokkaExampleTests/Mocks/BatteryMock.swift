//
//  BatteryMock.swift
//  MokkaExampleTests
//
//  Created by Daniel Rinser on 28.06.2019.
//  Copyright © 2019 Daniel Rinser. All rights reserved.
//

import XCTest
import Mokka
@testable import MokkaExample

class BatteryMock: Battery {
    let capacityProperty = PropertyMock<Double>(name: "capacity")
    var capacity: Double {
        get { return capacityProperty.get() }
        set { capacityProperty.set(newValue) }
    }
    
    let currentLevelProperty = PropertyMock<Double>(name: "currentLevel")
    var currentLevel: Double {
        get { return currentLevelProperty.get() }
        set { currentLevelProperty.set(newValue) }
    }
}
