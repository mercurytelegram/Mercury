//
//  LoggerService.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 02/06/24.
//

import Foundation
import os

class LoggerService {
    
    /// The logging level:
    /// - debug: Specify a log that will be used to debug only, no trace will be stored.
    /// - info: Specify a log that will be used to report certain behaviours, the log will be stored for future retrieval.
    /// - error: Specify a log that will be used to report an error, the log will be stored for future retrieval.
    /// - fatal: Specify a log that will be used to report an error that will cause the app to crash, the log will be stored for future retrieval.
    public enum Level: String {
        case debug = "Debug"
        case info = "Info"
        case error = "Error"
        case fatal = "Fatal"
    }
    
    private let subsystem: String
    private let category: String
    private let logger: Logger
    
    /// Init the logging service.
    ///
    /// - Parameter category: The class that will use the logger service.
    public init(_ category: Any) {
        self.category = "\(category)"
        
        #if DEBUG
        self.subsystem = "Mercury"
        #else
        self.subsystem = Bundle.main.bundleIdentifier ?? "Mercury"
        #endif
        
        self.logger = Logger(
            subsystem: self.subsystem,
            category: self.category
        )
    }
    
    /// Logs a string with a specified level and context
    ///
    /// - Parameter message: A string.
    /// - Parameter caller: The function calling the log, used to get a context related to the log.
    /// - Parameter level: The logging ``LoggerService/Level``
    public func log(_ message: String,
                    caller: String = #function,
                    level: Level = .debug) {
        
        let prefix: String = "[\(subsystem)] [\(level.rawValue)] [\(self.category)] [\(caller)]"
        
        switch level {
        case .debug:
            self.logger.debug("\(prefix) \(message)")
        case .info:
            self.logger.info("\(prefix) \(message)")
        case .error:
            self.logger.error("\(prefix) \(message)")
        case .fatal:
            self.logger.critical("\(prefix) \(message)")
        }
        
    }
    
    /// Logs a string with a specified level and context
    ///
    /// - Parameter object: An object that will be string described.
    /// - Parameter caller: The function calling the log, used to get a context related to the log.
    /// - Parameter level: The logging ``LoggerService/Level``
    public func log(_ object: Any?,
                    caller: String = #function,
                    level: Level = .debug) {
        self.log(String(describing: object), caller: caller, level: level)
    }
    
}
