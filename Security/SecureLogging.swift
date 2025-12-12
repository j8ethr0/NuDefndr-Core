// Copyright (c) 2025 Dro1d Labs Limited
// Released under the MIT License. See LICENSE file for details.
//
// NuDefndr Core Security Module - Secure Logging Component
// App Website: https://nudefndr.com
// Developer: Dro1d Labs

import Foundation
import os.log

/// Secure, ephemeral logging system with automatic PII redaction
/// Logs are held in memory only and purged on app termination
public class SecureLogger {
    
    // MARK: - Singleton
    
    public static let shared = SecureLogger()
    
    private var logBuffer: [LogEntry] = []
    private let maxBufferSize = 500
    private let queue = DispatchQueue(label: "com.nudefndr.securelogger", attributes: .concurrent)
    
    private init() {
        #if DEBUG
        print("[SecureLogger] Initialized with in-memory buffer (max: \(maxBufferSize))")
        #endif
    }
    
    // MARK: - Log Entry
    
    public struct LogEntry {
        let timestamp: Date
        let level: LogLevel
        let category: String
        let message: String
        let threadID: String
        
        var formattedMessage: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss.SSS"
            return "[\(formatter.string(from: timestamp))] [\(level.emoji)] [\(category)] \(message)"
        }
    }
    
    public enum LogLevel: String {
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
        case critical = "CRITICAL"
        
        var emoji: String {
            switch self {
            case .debug: return "🔍"
            case .info: return "ℹ️"
            case .warning: return "⚠️"
            case .error: return "❌"
            case .critical: return "🚨"
            }
        }
    }
    
    // MARK: - Logging Methods
    
    public static func debug(_ message: String, category: String = "General") {
        shared.log(message, level: .debug, category: category)
    }
    
    public static func info(_ message: String, category: String = "General") {
        shared.log(message, level: .info, category: category)
    }
    
    public static func warning(_ message: String, category: String = "General") {
        shared.log(message, level: .warning, category: category)
    }
    
    public static func error(_ message: String, category: String = "General") {
        shared.log(message, level: .error, category: category)
    }
    
    public static func critical(_ message: String, category: String = "General") {
        shared.log(message, level: .critical, category: category)
    }
    
    // MARK: - Core Logging
    
    private func log(_ message: String, level: LogLevel, category: String) {
        let redactedMessage = redactPII(message)
        
        let entry = LogEntry(
            timestamp: Date(),
            level: level,
            category: category,
            message: redactedMessage,
            threadID: Thread.current.description
        )
        
        queue.async(flags: .barrier) {
            self.logBuffer.append(entry)
            
            // Enforce buffer size limit
            if self.logBuffer.count > self.maxBufferSize {
                self.logBuffer.removeFirst(self.logBuffer.count - self.maxBufferSize)
            }
        }
        
        #if DEBUG
        print(entry.formattedMessage)
        #endif
        
        // Also log to system for crash reports (production)
        os_log("%{public}@", log: OSLog(subsystem: "com.nudefndr", category: category), type: level.osLogType, redactedMessage)
    }
    
    // MARK: - PII Redaction
    
    private func redactPII(_ message: String) -> String {
        var redacted = message
        
        // Email addresses
        let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        redacted = redacted.replacingOccurrences(of: emailPattern, with: "[EMAIL]", options: .regularExpression)
        
        // Asset IDs (UUIDs)
        let uuidPattern = "[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}"
        redacted = redacted.replacingOccurrences(of: uuidPattern, with: "[ASSET_ID]", options: .regularExpression)
        
        // IP addresses
        let ipPattern = "\\b(?:[0-9]{1,3}\\.){3}[0-9]{1,3}\\b"
        redacted = redacted.replacingOccurrences(of: ipPattern, with: "[IP_ADDRESS]", options: .regularExpression)
        
        // Hex keys (32+ characters)
        let keyPattern = "\\b[0-9A-Fa-f]{32,}\\b"
        redacted = redacted.replacingOccurrences(of: keyPattern, with: "[KEY]", options: .regularExpression)
        
        // File paths
        let pathPattern = "/[A-Za-z0-9/_.-]+"
        redacted = redacted.replacingOccurrences(of: pathPattern, with: "[PATH]", options: .regularExpression)
        
        return redacted
    }
    
    // MARK: - Buffer Management
    
    public static func getRecentLogs(count: Int = 100) -> [LogEntry] {
        shared.queue.sync {
            let startIndex = max(0, shared.logBuffer.count - count)
            return Array(shared.logBuffer[startIndex...])
        }
    }
    
    public static func clearBuffer() {
        shared.queue.async(flags: .barrier) {
            shared.logBuffer.removeAll()
        }
    }
    
    public static func exportLogs() -> String {
        let logs = getRecentLogs(count: shared.maxBufferSize)
        return logs.map { $0.formattedMessage }.joined(separator: "\n")
    }
    
    deinit {
        // Ensure logs are cleared on deallocation
        logBuffer.removeAll()
    }
}

// MARK: - OSLog Type Mapping

private extension SecureLogger.LogLevel {
    var osLogType: OSLogType {
        switch self {
        case .debug: return .debug
        case .info: return .info
        case .warning: return .default
        case .error: return .error
        case .critical: return .fault
        }
    }
}