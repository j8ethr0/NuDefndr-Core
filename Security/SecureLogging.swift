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
import UIKit

/// Privacy-preserving logging system with automatic PII redaction
final class SecureLogger {
	
	// MARK: - Log Levels
	
	enum LogLevel: Int, Comparable {
		case debug = 0
		case info = 1
		case warning = 2
		case error = 3
		case critical = 4
		
		static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
			lhs.rawValue < rhs.rawValue
		}
		
		var osLogType: OSLogType {
			switch self {
			case .debug:    return .debug
			case .info:     return .info
			case .warning:  return .default
			case .error:    return .error
			case .critical: return .fault
			}
		}
		
		var emoji: String {
			switch self {
			case .debug:    return "🔍"
			case .info:     return "ℹ️"
			case .warning:  return "⚠️"
			case .error:    return "❌"
			case .critical: return "🚨"
			}
		}
	}
	
	// MARK: - Configuration
	
	private static var minimumLogLevel: LogLevel = .info
	private static let subsystem = "com.nudefndr.core.security"
	
	// MARK: - Logging
	
	static func log(
		_ level: LogLevel,
		category: String,
		_ message: String,
		file: String = #file,
		function: String = #function,
		line: Int = #line
	) {
		guard level >= minimumLogLevel else { return }
		
		let redacted = redactSensitiveData(message)
		let formatted = formatLogMessage(level, category: category, message: redacted,
										 file: file, function: function, line: line)
		
		os_log("%{public}@", log: .init(subsystem: subsystem, category: category),
			   type: level.osLogType, formatted)
		
		appendToBuffer(formatted)
	}
	
	// MARK: - Convenience
	
	static func debug(_ msg: String, category: String = "General") { log(.debug, category: category, msg) }
	static func info(_ msg: String, category: String = "General") { log(.info, category: category, msg) }
	static func warning(_ msg: String, category: String = "General") { log(.warning, category: category, msg) }
	static func error(_ msg: String, category: String = "General") { log(.error, category: category, msg) }
	static func critical(_ msg: String, category: String = "General") { log(.critical, category: category, msg) }
	
	// MARK: - Redaction
	
	private static func redactSensitiveData(_ message: String) -> String {
		var redacted = message
		
		// PHAsset identifiers (broader)
		redacted = redactPattern(redacted, pattern: "[A-F0-9\\-]{20,}", replacement: "[ASSET_ID]")
		
		// File paths
		redacted = redactPattern(redacted, pattern: "/Users/[^/]+/", replacement: "/Users/[REDACTED]/")
		redacted = redactPattern(redacted, pattern: "/private/var/mobile/[^/]+/", replacement: "/private/var/mobile/[REDACTED]/")
		
		// Email
		redacted = redactPattern(redacted, pattern: "[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}", replacement: "[EMAIL]", options: .caseInsensitive)
		
		// Phone
		redacted = redactPattern(redacted, pattern: "\\+?[1-9]\\d{8,14}", replacement: "[PHONE]")
		
		// Keys
		redacted = redactPattern(redacted, pattern: "[A-Fa-f0-9]{32,}", replacement: "[KEY]")
		
		// IP
		redacted = redactPattern(redacted, pattern: "\\b(?:[0-9]{1,3}\\.){3}[0-9]{1,3}\\b", replacement: "[IP_ADDRESS]")
		
		return redacted
	}
	
	private static func redactPattern(
		_ input: String,
		pattern: String,
		replacement: String,
		options: NSRegularExpression.Options = []
	) -> String {
		guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
			return input
		}
		let range = NSRange(input.startIndex..., in: input)
		return regex.stringByReplacingMatches(
			in: input, options: [], range: range, withTemplate: replacement
		)
	}
	
	// MARK: - Formatting
	
	private static func formatLogMessage(
		_ level: LogLevel,
		category: String,
		message: String,
		file: String,
		function: String,
		line: Int
	) -> String {
		let fileName = URL(fileURLWithPath: file).lastPathComponent
		let ts = ISO8601DateFormatter().string(from: Date())
		
		return "[\(ts)] \(level.emoji) [\(category)] \(fileName):\(line) \(function)\n  → \(message)"
	}
	
	// MARK: - Buffer
	
	private static var logBuffer: [String] = []
	private static let maxBuffer = 1000
	private static let queue = DispatchQueue(label: "com.nudefndr.logbuffer")
	
	private static func appendToBuffer(_ msg: String) {
		queue.async {
			logBuffer.append(msg)
			if logBuffer.count > maxBuffer { logBuffer.removeFirst() }
		}
	}
	
	static func getRecentLogs(count: Int = 100) -> [String] {
		queue.sync { Array(logBuffer.suffix(count)) }
	}
	
	static func clearBuffer() {
		queue.async { logBuffer.removeAll() }
	}
	
	// MARK: - Export
	
	struct LogExportPackage {
		let logs: [String]
		let exportDate: Date
		let deviceInfo: String
		let appVersion: String
	}
	
	static func exportLogs() -> LogExportPackage {
		let logs = getRecentLogs(count: 1000)
		let deviceInfo = "\(UIDevice.current.model) - iOS \(UIDevice.current.systemVersion)"
		let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
		
		return .init(
			logs: logs,
			exportDate: Date(),
			deviceInfo: deviceInfo,
			appVersion: version
		)
	}
}

// MARK: - Security Events

extension SecureLogger {
	static func logSecurityEvent(_ event: SecurityEvent, details: String = "") {
		let msg = details.isEmpty ? event.rawValue : "\(event.rawValue): \(details)"
		log(.warning, category: "Security", msg)
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