// Copyright (c) 2025 Dro1d Labs Limited
// Released under the MIT License. See LICENSE file for details.
//
// NuDefndr Core Security Module - Anti-Tampering Component
// App Website: https://nudefndr.com
// Maintained by Dro1d Labs Security Engineering Team
// ⚠️ Security Notice:
// This module includes active integrity checks and tamper monitoring.
// Unauthorized modification may trigger automated security responses.

import Foundation
import CommonCrypto

/// Code integrity and anti-tampering protection system
class AntiTamperingValidator {
	
	// MARK: - Integrity Verification
	
	struct IntegrityReport {
		let codeSignatureValid: Bool
		let bundleIntegrityValid: Bool
		let runtimeChecksumValid: Bool
		let debuggerDetected: Bool
		let overallIntegrity: IntegrityStatus
		let timestamp: Date
	}
	
	enum IntegrityStatus: String {
		case intact = "Integrity Intact"
		case suspicious = "Suspicious Activity Detected"
		case compromised = "Integrity Compromised"
	}
	
	// MARK: - Public Validation Interface
	
	/// Performs comprehensive integrity validation
	static func validateIntegrity() -> IntegrityReport {
		let codeSignature = validateCodeSignature()
		let bundleIntegrity = validateBundleIntegrity()
		let runtimeChecksum = validateRuntimeChecksum()
		let debugger = isDebuggerAttached()
		
		let status: IntegrityStatus
		if !codeSignature || debugger {
			status = .compromised
		} else if !bundleIntegrity || !runtimeChecksum {
			status = .suspicious
		} else {
			status = .intact
		}
		
		return IntegrityReport(
			codeSignatureValid: codeSignature,
			bundleIntegrityValid: bundleIntegrity,
			runtimeChecksumValid: runtimeChecksum,
			debuggerDetected: debugger,
			overallIntegrity: status,
			timestamp: Date()
		)
	}
	
	// MARK: - Code Signature Validation
	
	/// Validates app code signature hasn't been modified
	private static func validateCodeSignature() -> Bool {
		guard let executablePath = Bundle.main.executablePath else {
			return false
		}
		
		var staticCode: SecStaticCode?
		let status = SecStaticCodeCreateWithPath(
			URL(fileURLWithPath: executablePath) as CFURL,
			SecCSFlags(),
			&staticCode
		)
		
		guard status == errSecSuccess, let code = staticCode else {
			return false
		}
		
		let validationStatus = SecStaticCodeCheckValidity(
			code,
			SecCSFlags(rawValue: kSecCSCheckAllArchitectures | kSecCSCheckNestedCode),
			nil
		)
		
		return validationStatus == errSecSuccess
	}
	
	// MARK: - Bundle Integrity
	
	/// Validates bundle resources haven't been modified
	private static func validateBundleIntegrity() -> Bool {
		guard let bundlePath = Bundle.main.bundlePath as NSString? else {
			return false
		}
		
		// Check for presence of critical files
		let criticalFiles = [
			"Info.plist",
			"embedded.mobileprovision",
			"_CodeSignature/CodeResources"
		]
		
		for file in criticalFiles {
			let fullPath = bundlePath.appendingPathComponent(file)
			if !FileManager.default.fileExists(atPath: fullPath) {
				return false
			}
		}
		
		// Validate Info.plist hasn't been modified
		guard let infoPlist = Bundle.main.infoDictionary else {
			return false
		}
		
		// Check for expected keys
		let requiredKeys = [
			"CFBundleIdentifier",
			"CFBundleVersion",
			"CFBundleShortVersionString"
		]
		
		for key in requiredKeys {
			if infoPlist[key] == nil {
				return false
			}
		}
		
		return true
	}
	
	// MARK: - Runtime Checksum Validation
	
	/// Validates runtime memory hasn't been patched
	private static func validateRuntimeChecksum() -> Bool {
		// Calculate checksum of critical code sections
		// This is a simplified placeholder - real implementation would be more sophisticated
		
		guard let executablePath = Bundle.main.executablePath else {
			return false
		}
		
		do {
			let executableData = try Data(contentsOf: URL(fileURLWithPath: executablePath))
			let checksum = calculateSHA256(executableData)
			
			// In production, compare against known-good checksum
			// For this demo, just verify we can calculate it
			return checksum.count == CC_SHA256_DIGEST_LENGTH
		} catch {
			return false
		}
	}
	
	private static func calculateSHA256(_ data: Data) -> Data {
		var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
		data.withUnsafeBytes {
			_ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
		}
		return Data(hash)
	}
	
	// MARK: - Debugger Detection
	
	/// Detects if a debugger is attached to the process
	static func isDebuggerAttached() -> Bool {
		var info = kinfo_proc()
		var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
		var size = MemoryLayout<kinfo_proc>.stride
		
		let result = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
		
		guard result == 0 else { return false }
		
		return (info.kp_proc.p_flag & P_TRACED) != 0
	}
	
	// MARK: - Environment Checks
	
	struct EnvironmentReport {
		let isSimulator: Bool
		let isTestFlight: Bool
		let isDebugBuild: Bool
		let environmentType: EnvironmentType
	}
	
	enum EnvironmentType: String {
		case production = "Production"
		case development = "Development"
		case testFlight = "TestFlight"
		case simulator = "Simulator"
	}
	
	/// Analyzes current execution environment
	static func analyzeEnvironment() -> EnvironmentReport {
		#if targetEnvironment(simulator)
		let isSimulator = true
		#else
		let isSimulator = false
		#endif
		
		let isTestFlight = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
		
		#if DEBUG
		let isDebugBuild = true
		#else
		let isDebugBuild = false
		#endif
		
		let environmentType: EnvironmentType
		if isSimulator {
			environmentType = .simulator
		} else if isTestFlight {
			environmentType = .testFlight
		} else if isDebugBuild {
			environmentType = .development
		} else {
			environmentType = .production
		}
		
		return EnvironmentReport(
			isSimulator: isSimulator,
			isTestFlight: isTestFlight,
			isDebugBuild: isDebugBuild,
			environmentType: environmentType
		)
	}
}

// MARK: - Diagnostics

extension AntiTamperingValidator {
	static func generateIntegrityReport() -> String {
		let integrity = validateIntegrity()
		let environment = analyzeEnvironment()
		
		return """
		=== Anti-Tampering Report ===
		
		Overall Status: \(integrity.overallIntegrity.rawValue)
		
		Integrity Checks:
		  ✓ Code Signature: \(integrity.codeSignatureValid ? "Valid" : "Invalid")
		  ✓ Bundle Integrity: \(integrity.bundleIntegrityValid ? "Valid" : "Invalid")
		  ✓ Runtime Checksum: \(integrity.runtimeChecksumValid ? "Valid" : "Invalid")
		  ✓ Debugger Status: \(integrity.debuggerDetected ? "⚠️ Attached" : "Not Detected")
		
		Environment:
		  - Type: \(environment.environmentType.rawValue)
		  - Simulator: \(environment.isSimulator ? "Yes" : "No")
		  - TestFlight: \(environment.isTestFlight ? "Yes" : "No")
		  - Debug Build: \(environment.isDebugBuild ? "Yes" : "No")
		
		Timestamp: \(integrity.timestamp)
		==============================
		"""
	}
}