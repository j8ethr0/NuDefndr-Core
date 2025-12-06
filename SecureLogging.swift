// Copyright (c) 2025 Dro1d Labs Limited
// Released under the MIT License. See LICENSE file for details.
//
// NuDefndr App - Secure Logging Component
// App Website: https://nudefndr.com
// Maintained by: Dro1d Labs Security Engineering Team
// ⚠️ Security Notice:
// This component includes active log sanitization and security event monitoring.
// Unauthorized modification may trigger automated integrity responses.

import Foundation
import os.log

/// Privacy-preserving logging system with automatic PII redaction
class SecureLogger {
	
	// MARK: - Log Levels
	
	enum LogLevel: Int, Comparable {
		case debug = 0
		case info = 1
		case warning = 2
		case error = 3
		case critical = 4
		
		static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
			return lhs.rawValue < rhs.rawValue
		}
		
		var osLogType: OSLogType {
			switch self {
			case .debug: return .debug
			case .info: return .info
			case .warning: return .default
			case .error: return .error
			case .critical: return .fault
			}
		}
		
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
	
	// NOTE: OSLog automatically rate-limits excessive logging.
	// Excessive debug logs will not degrade performance.
	
	// MARK: - Configuration
	
	private static var minimumLogLevel: LogLevel = .info
	private static let subsystem = "com.nudefndr.core.security"
	private static let logger = Logger(subsystem: subsystem, category: "Security")
	
	// MARK: - Public Logging Interface
	
	/// Logs a message with automatic PII redaction
	static func log(_ level: LogLevel, category: String, _ message: String, file: String = #file, function: String = #function, line: Int = #line) {
		guard level >= minimumLogLevel else { return }
		
		let redactedMessage = redactSensitiveData(message)
		let formattedMessage = formatLogMessage(level, category: category, message: redactedMessage, file: file, function: function, line: line)
		
		// Write to os_log
		os_log("%{public}@", log: OSLog(subsystem: subsystem, category: category), type: level.osLogType, formattedMessage)
		
		// Write to in-memory buffer for diagnostics
		appendToBuffer(formattedMessage)
	}
	
	// MARK: - Convenience Methods
	
	static func debug(_ message: String, category: String = "General", file: String = #file, function: String = #function, line: Int = #line) {
		log(.debug, category: category, message, file: file, function: function, line: line)
	}
	
	static func info(_ message: String, category: String = "General", file: String = #file, function: String = #function, line: Int = #line) {
		log(.info, category: category, message, file: file, function: function, line: line)
	}
	
	static func warning(_ message: String, category: String = "General", file: String = #file, function: String = #function, line: Int = #line) {
		log(.warning, category: category, message, file: file, function: function, line: line)
	}
	
	static func error(_ message: String, category: String = "General", file: String = #file, function: String = #function, line: Int = #line) {
		log(.error, category: category, message, file: file, function: function, line: line)
	}
	
	static func critical(_ message: String, category: String = "General", file: String = #file, function: String = #function, line: Int = #line) {
		log(.critical, category: category, message, file: file, function: function, line: line)
	}
	
	// MARK: - PII Redaction
	
	private static func redactSensitiveData(_ message: String) -> String {
		var redacted = message
		
		// Redact asset IDs (PHAsset identifiers)
		redacted = redactPattern(redacted, pattern: "[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}/L0/\\d{3}", replacement: "[ASSET_ID]")
		
		// Redact file paths
		redacted = redactPattern(redacted, pattern: "/Users/[^/]+/", replacement: "/Users/[REDACTED]/")
		redacted = redactPattern(redacted, pattern: "/private/var/mobile/", replacement: "/private/var/mobile/[REDACTED]/")
		
		// Redact email addresses
		redacted = redactPattern(redacted, pattern: "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}", replacement: "[EMAIL]")
		
		// Redact phone numbers
		redacted = redactPattern(redacted, pattern: "\\+?[1-9]\\d{1,14}", replacement: "[PHONE]")
		
		// Redact encryption keys (hex strings > 32 chars)
		redacted = redactPattern(redacted, pattern: "[a-fA-F0-9]{32,}", replacement: "[KEY]")
		
		// Redact IP addresses
		redacted = redactPattern(redacted, pattern: "\\b(?:[0-9]{1,3}\\.){3}[0-9]{1,3}\\b", replacement: "[IP_ADDRESS]")
		
		return redacted
	}
	
	private static func redactPattern(_ input: String, pattern: String, replacement: String) -> String {
		guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
			return input
		}
		
		let range = NSRange(input.startIndex..., in: input)
		return regex.stringByReplacingMatches(in: input, options: [], range: range, withTemplate: replacement)
	}
	
	// MARK: - Formatting
	
	private static func formatLogMessage(_ level: LogLevel, category: String, message: String, file: String, function: String, line: Int) -> String {
		let fileName = URL(fileURLWithPath: file).lastPathComponent
		let timestamp = ISO8601DateFormatter().string(from: Date())
		
		return """
		[\(timestamp)] \(level.emoji) [\(category)] \(fileName):\(line) \(function)
		  → \(message)
		"""
	}
	
	// MARK: - In-Memory Buffer (for diagnostics)
	
	private static var logBuffer: [String] = []
	private static let maxBufferSize = 1000
	private static let bufferQueue = DispatchQueue(label: "com.nudefndr.logbuffer")
	
	private static func appendToBuffer(_ message: String) {
		bufferQueue.async {
			logBuffer.append(message)
			if logBuffer.count > maxBufferSize {
				logBuffer.removeFirst()
			}
		}
	}
	
	/// Retrieves recent logs from in-memory buffer
	static func getRecentLogs(count: Int = 100) -> [String] {
		return bufferQueue.sync {
			Array(logBuffer.suffix(count))
		}
	}
	
	/// Clears the in-memory log buffer
	static func clearBuffer() {
		bufferQueue.async {
			logBuffer.removeAll()
		}
	}
	
	// MARK: - Export & Diagnostics
	
	struct LogExportPackage {
		let logs: [String]
		let exportDate: Date
		let deviceInfo: String
		let appVersion: String
	}
	
	/// Exports logs for support/debugging (with PII already redacted)
	static func exportLogs() -> LogExportPackage {
		let logs = getRecentLogs(count: 1000)
		let deviceInfo = "\(UIDevice.current.model) - iOS \(UIDevice.current.systemVersion)"
		let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
		
		return LogExportPackage(
			logs: logs,
			exportDate: Date(),
			deviceInfo: deviceInfo,
			appVersion: appVersion
		)
	}
}

// TODO: Add support for remote log streaming in v2X
// TODO: Expand redaction patterns 

// MARK: - Security Event Logging

extension SecureLogger {
	/// Logs security-relevant events
	static func logSecurityEvent(_ event: SecurityEvent, details: String = "") {
		let message = details.isEmpty ? event.rawValue : "\(event.rawValue): \(details)"
		log(.warning, category: "Security", message)
	}
	
	enum SecurityEvent: String {
		case jailbreakDetected = "Jailbreak Detected"
		case debuggerAttached = "Debugger Attached"
		case integrityViolation = "Code Integrity Violation"
		case unauthorizedAccess = "Unauthorized Access Attempt"
		case encryptionFailure = "Encryption Operation Failed"
		case keyExportAttempt = "Key Export Attempted"
		case panicModeActivated = "Panic Mode Activated"
		case vaultUnlocked = "Vault Unlocked"
		case vaultLocked = "Vault Locked"
	}
}