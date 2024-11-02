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
/// - Note: This property wrapper should be used only on the main actor, as it uses the ``AppState``
@MainActor
@propertyWrapper
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
        if AppState.shared.isMock == false {
            if let value = value { return value }
            value = valueInit()
            return value!
        }
        
        if let mock = mock { return mock }
        self.mock = mockInit()
        return mock!
    }
}
