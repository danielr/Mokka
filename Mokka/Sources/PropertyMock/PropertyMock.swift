//
// Copyright (c) 2019 Daniel Rinser and contributors.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
// OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation

/// A `PropertyMock` allows to provide fake values for a property and record
/// whether a property has been read or set.
///
/// The property mock is generic over the property type.
///
/// Given a property requirement in a protocol:
///
///     var foo: Int { get set }
///
/// you can use the property mock like this:
///
///     let fooProperty = PropertyMock<Int>(name: "foo")
///     var foo: Int {
///         get { return fooProperty.get() }
///         set { fooProperty.set(newValue) }
///     }
///
/// For a read-only property requirement, you can omit the setter. Given this requirement:
///
///     var bar: Int { get }
///
/// you can use the property mock like this:
///
///     let barProperty = PropertyMock<Int>(name: "bar")
///     var bar: Int {
///         return barProperty.get()
///     }
///
public class PropertyMock<T> {
    
    /// The name of the mocked property.
    public let name: String?

    /// The value of the mocked property.
    ///
    /// This value can be either set from outside to fake the property's value, or it
    /// can be read to verify if the expected value has been set.
    public var value: T?
    
    /// Determines whether the property value has been read by the system under test.
    public private(set) var hasBeenRead: Bool = false

    /// Determines whether the property value has been set by the system under test.
    public private(set) var hasBeenSet: Bool = false
    
    /// Creates a new instance of a property mock with the specified name.
    ///
    /// - parameters:
    ///     - name: (optional) The name of the property. This will only be used for informational
    ///             purposes (e.g. by matchers or in error messages).
    public init(name: String?) {
        self.name = name
    }

    /// Get the current value of the property. If there is no value set, this method
    /// will fail.
    ///
    /// Use this when implementing the getter of the mocked property.
    ///
    /// - returns: The current value of the mocked property.
    public func get() -> T {
        hasBeenRead = true
        
        guard let value = value else {
            if let propertyName = name {
                preconditionFailure("No value for property '\(propertyName)'")
            } else {
                preconditionFailure("No value for property")
            }
        }
        return value
    }
    
    /// Record setting a new value for this property.
    ///
    /// Use this when implementing the setter of the mocked property.
    ///
    /// **Do not use this method in your testing code to stub/fake a value for this
    /// property!** Assign to the `value` property directly, in this case.
    ///
    /// - parameters:
    ///     - newValue: The new value that has been set to the property.
    public func set(_ newValue: T) {
        hasBeenSet = true
        value = newValue
    }
    
    /// Reset the mock to its initial state. This will set the value to nil and reset
    /// the `hasBeenRead` and `hasBeenSet` flags.
    public func reset() {
        value = nil
        hasBeenRead = false
        hasBeenSet = false
    }
}
