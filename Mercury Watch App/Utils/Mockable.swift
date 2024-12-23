//
//  Mockable.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 2/11/24.
//

import Foundation
import SwiftUI


/// A property wrapper that provides mockable values for testing or debugging.
/// It allows for lazy initialization of both the main and mock values, depending
/// on the application state.
///
/// The `Mockable` wrapper can be particularly useful when you want to replace a
/// real implementation with a mock for testing purposes, without needing to modify
/// the wrapped property's code.
///
@propertyWrapper
@dynamicMemberLookup
public class Mockable<T> {
    
    /// The actual value to be used in non-mock scenarios, initialized on demand.
    private var value: T?
    
    /// The mock value to be used in mock scenarios, initialized on demand.
    private var mock: T?
    
    /// Closure used to initialize the mock value if `AppState.shared.isMock` is `true`.
    private let mockInit: () -> T
    
    /// Closure used to initialize the main value if `AppState.shared.isMock` is `false`.
    private let valueInit: () -> T
    
    /// Initializes the property wrapper with a provided main value and a mock value.
    ///
    /// This initializer allocates immediatly both the `wrappedValue` and the `mock` objects.
    ///
    /// - Parameters:
    ///   - wrappedValue: The main value to be used in production.
    ///   - mock: The mock value to be used when `AppState.shared.isMock` is `true`.
    init(wrappedValue: T, mock: T) {
        self.valueInit = { wrappedValue }
        self.mockInit = { mock }
    }
    
    /// Initializes the property wrapper with closures for lazy initialization
    /// of the main and mock values.
    ///
    /// Use this initializer when you need lazy initialization of both the mock
    /// and the main value to prevent unnecessary creation of the objects.
    ///
    /// - Parameters:
    ///   - wrappedValue: A closure that returns the main value.
    ///   - mockInit: A closure that returns the mock value.
    init(wrappedValue: @escaping () -> T, mockInit: @escaping () -> T) {
        self.valueInit = wrappedValue
        self.mockInit = mockInit
    }
    
    /// Returns either the main or mock value based on the application state.
    public var wrappedValue: T {
        get {
            if AppState.shared.isMock == false {
                if let value = value { return value }
                value = valueInit()
                return value!
            }
            
            if let mock = mock { return mock }
            self.mock = mockInit()
            return mock!
        }
        
        set {
            if AppState.shared.isMock == false {
                value = newValue
            } else {
                mock = newValue
            }
        }
    }
    
    public subscript<U>(dynamicMember keyPath: KeyPath<T, U>) -> U {
        wrappedValue[keyPath: keyPath]
    }
    
    public subscript<U>(dynamicMember keyPath: WritableKeyPath<T, U>) -> U {
        get { wrappedValue[keyPath: keyPath] }
        set { wrappedValue[keyPath: keyPath] = newValue }
    }
}

extension Mockable {
    /// A helper function to create a `State` instance of `Mockable`, wrapping both a value and a mock initializer.
    ///
    /// This function enables initializing a `@State` `@Mockable` variable later in the view’s initializer, allowing you to pass parameters to the initializer of the type `T`
    ///
    /// - Returns: A `State` instance containing the `Mockable` wrapped type.
    ///
    /// ### Usage Example
    /// ```swift
    /// @State
    /// @Mockable
    /// var vm: ViewModel
    ///
    /// init() {
    ///     _vm = Mockable.state(
    ///         value: { ViewModel("Value") },
    ///         mock: { ViewModelMock("Value") }
    ///     )
    /// }
    /// ```
    ///
    /// In this example, the `vm` property is a `@State` property that uses the `@Mockable` property wrapper.
    /// By calling `Mockable.state(value:mock:)` within the initializer, parameters can be passed to the `ViewModel` initializers.
    static func state(
        value: @escaping () -> T,
        mock: @escaping () -> T
    ) -> State<Mockable<T>> {
        return State(wrappedValue: Mockable(
            wrappedValue: value,
            mockInit: mock
        ))
    }
}
