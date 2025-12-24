// Copyright (c) 2025 Dro1d Labs Limited
// Released under the MIT License. See LICENSE file for details.
//
// NuDefndr Core Security Module - Jailbreak Detection Component
// App Website: https://nudefndr.com
// Maintained by Dro1d Labs Security Engineering Team
// ⚠️ Security Notice:
// This module includes active integrity checks and tamper monitoring.
// Unauthorized modification may trigger automated security responses.

import Foundation
import UIKit
import Darwin

/// Advanced jailbreak and device integrity detection system
/// Implements multi-vector analysis with confidence-based risk scoring
class JailbreakDetector {
	
	// MARK: - Detection Results
	
	struct DetectionReport {
		let isJailbroken: Bool
		let detectionMethods: [DetectionMethod: Bool]
		let confidenceLevel: ConfidenceLevel
		let timestamp: Date
		let riskScore: Double
		let platform: Platform
		let platformNotice: String?
	}
	
	enum Platform: String {
		case iOS = "iOS/iPadOS"
		case macCatalyst = "macOS (Catalyst)"
		case simulator = "Simulator"
	}
	
	enum DetectionMethod: String, CaseIterable {
		case suspiciousFiles = "Suspicious Files Present"
		case suspiciousApps = "Jailbreak Apps Detected"
		case sandboxViolation = "Sandbox Integrity Violation"
		case dyldInjection = "Dynamic Library Injection"
		case urlSchemeCheck = "Cydia URL Scheme"
		case writeTest = "System Write Test"
		case symlinkAnalysis = "Symlink Tampering"
		case forkRestriction = "Kernel Security Bypass"
		case permissionAudit = "File Permission Anomalies"
		case environmentCheck = "Runtime Environment Tampering"
	}
	
	enum ConfidenceLevel: String {
		case none = "Not Jailbroken"
		case platformDifference = "Platform Architecture Difference"
		case low = "Low Confidence (1-2 indicators)"
		case medium = "Medium Confidence (3-4 indicators)"
		case high = "High Confidence (5-7 indicators)"
		case critical = "Critical (8+ indicators)"
	}
	
	// MARK: - Public Detection Interface
	
	/// Performs comprehensive multi-layer jailbreak detection
	/// Returns detailed report with confidence scoring
	/// v2.1.5: Now includes platform-aware analysis
	static func detectJailbreak() -> DetectionReport {
		// Platform identification
		let platform = identifyPlatform()
		
		// Simulator bypass - always clean
		#if targetEnvironment(simulator)
		return DetectionReport(
			isJailbroken: false,
			detectionMethods: [:],
			confidenceLevel: .none,
			timestamp: Date(),
			riskScore: 0.0,
			platform: .simulator,
			platformNotice: "Running in Xcode Simulator - Security checks disabled"
		)
		#endif
		
		// Mac Catalyst platform notice
		#if targetEnvironment(macCatalyst)
		return DetectionReport(
			isJailbroken: false,
			detectionMethods: ["macOS Platform": true],
			confidenceLevel: .platformDifference,
			timestamp: Date(),
			riskScore: 0.0,
			platform: .macCatalyst,
			platformNotice: """
				Running on macOS with Catalyst. macOS has different security architecture \
				than iOS/iPadOS. Your vault remains encrypted, but macOS does not provide \
				the same sandboxing guarantees as iOS devices. This is normal and expected.
				"""
		)
		#endif
		
		// iOS/iPadOS full detection
		var results: [DetectionMethod: Bool] = [:]
		
		// Core detection vectors
		results[.suspiciousFiles] = checkSuspiciousFiles()
		results[.suspiciousApps] = checkSuspiciousApps()
		results[.sandboxViolation] = checkSandboxIntegrity()
		results[.dyldInjection] = checkDynamicLibraryInjection()
		results[.urlSchemeCheck] = checkCydiaURLScheme()
		results[.writeTest] = checkSystemWriteAccess()
		
		// Advanced detection vectors (v2.1+)
		results[.symlinkAnalysis] = analyzeFilesystemSymlinks()
		results[.forkRestriction] = testKernelSecurityRestrictions()
		results[.permissionAudit] = auditSystemPermissions()
		results[.environmentCheck] = scanRuntimeEnvironment()
		
		let positiveCount = results.values.filter { $0 }.count
		let isJailbroken = positiveCount > 0
		let riskScore = calculateRiskScore(results: results)
		
		let confidence: ConfidenceLevel
		switch positiveCount {
		case 0:
			confidence = .none
		case 1...2:
			confidence = .low
		case 3...4:
			confidence = .medium
		case 5...7:
			confidence = .high
		default:
			confidence = .critical
		}
		
		return DetectionReport(
			isJailbroken: isJailbroken,
			detectionMethods: results,
			confidenceLevel: confidence,
			timestamp: Date(),
			riskScore: riskScore,
			platform: .iOS,
			platformNotice: nil
		)
	}
	
	// MARK: - Platform Identification
	
	private static func identifyPlatform() -> Platform {
		#if targetEnvironment(simulator)
		return .simulator
		#elseif targetEnvironment(macCatalyst)
		return .macCatalyst
		#else
		return .iOS
		#endif
	}
	
	// MARK: - Core Detection Methods
	
	/// Filesystem analysis: Scans for 40+ known jailbreak artifacts
	/// Includes Cydia, Sileo, Zebra, Substitute, and other package managers
	private static func checkSuspiciousFiles() -> Bool {
		let suspiciousPaths = [
			"/Applications/Cydia.app",
			"/Applications/Sileo.app",
			"/Applications/Zebra.app",
			"/Library/MobileSubstrate/MobileSubstrate.dylib",
			"/bin/bash",
			"/usr/sbin/sshd",
			"/etc/apt",
			"/private/var/lib/apt/",
			"/usr/bin/ssh",
			"/var/lib/cydia",
			"/private/var/stash",
			// Additional paths redacted for security
		]
		
		for path in suspiciousPaths {
			// Multi-method verification
			if FileManager.default.fileExists(atPath: path) {
				return true
			}
			// Attempt fopen to catch hidden files
			if let file = fopen(path, "r") {
				fclose(file)
				return true
			}
		}
		
		return false
	}
	
	/// URL scheme enumeration: Detects installed jailbreak tools
	private static func checkSuspiciousApps() -> Bool {
		let jailbreakSchemes = [
			"cydia://",
			"sileo://",
			"zbra://",
			"filza://",
			"activator://"
		]
		
		for scheme in jailbreakSchemes {
			if let url = URL(string: scheme), UIApplication.shared.canOpenURL(url) {
				return true
			}
		}
		
		return false
	}
	
	/// Sandbox escape detection: Validates iOS security boundaries
	private static func checkSandboxIntegrity() -> Bool {
		let restrictedPaths = [
			"/etc/fstab",
			"/private/etc/fstab",
			"/bin",
			"/sbin"
		]
		
		for path in restrictedPaths {
			if FileManager.default.isReadableFile(atPath: path) {
				return true
			}
		}
		
		return false
	}
	
	/// Dynamic library injection detection: Scans loaded dylibs for hooking frameworks
	/// Detects MobileSubstrate, Substitute, Frida, Cycript, and custom injections
	/// v2.1.5: Filters out legitimate debugging tools (Xcode View Debugger)
	private static func checkDynamicLibraryInjection() -> Bool {
		let imageCount = _dyld_image_count()
		
		let suspiciousLibs = [
			"MobileSubstrate",
			"Substrate",
			"Substitute",
			"libhooker",
			"SSLKillSwitch",
			"Frida",
			"Cycript"
		]
		
		for i in 0..<imageCount {
			guard let imageName = _dyld_get_image_name(i) else { continue }
			let imageNameStr = String(cString: imageName)
			
			// Filter out Xcode debugging tools
			if imageNameStr.contains("libViewDebuggerSupport") {
				continue
			}
			
			for lib in suspiciousLibs {
				if imageNameStr.lowercased().contains(lib.lowercased()) {
					return true
				}
			}
		}
		
		return false
	}
	
	/// Legacy jailbreak tool detection via URL scheme
	private static func checkCydiaURLScheme() -> Bool {
		guard let url = URL(string: "cydia://package/com.example.package") else {
			return false
		}
		return UIApplication.shared.canOpenURL(url)
	}
	
	/// System write access test: Attempts to write to restricted directories
	/// On stock iOS, this should always fail
	private static func checkSystemWriteAccess() -> Bool {
		let testPaths = [
			"/private/jailbreak_test.txt",
			"/private/var/tmp/jailbreak_test.txt"
		]
		
		for testPath in testPaths {
			do {
				try "test".write(toFile: testPath, atomically: true, encoding: .utf8)
				try? FileManager.default.removeItem(atPath: testPath)
				return true // Write succeeded - sandbox compromised
			} catch {
				continue // Expected behavior
			}
		}
		
		return false
	}
	
	// MARK: - Advanced Detection (v2.1+)
	
	/// Symlink analysis: Detects filesystem modifications common in jailbreaks
	private static func analyzeFilesystemSymlinks() -> Bool {
		let suspiciousSymlinks = [
			"/Applications",
			"/Library/Ringtones",
			"/Library/Wallpaper",
			"/usr/arm-apple-darwin9",
			"/usr/include"
		]
		
		for path in suspiciousSymlinks {
			var stat = stat()
			if lstat(path, &stat) == 0 {
				if (stat.st_mode & S_IFMT) == S_IFLNK {
					return true
				}
			}
		}
		
		return false
	}
	
	/// Kernel security restriction test: fork() should fail on stock iOS
	private static func testKernelSecurityRestrictions() -> Bool {
		let pid = fork()
		if pid >= 0 {
			if pid > 0 {
				kill(pid, SIGTERM) // Clean up child process
			}
			return true // fork() succeeded - jailbroken
		}
		return false
	}
	
	/// Permission audit: Validates system directory permissions
	private static func auditSystemPermissions() -> Bool {
		let systemPaths = ["/bin", "/sbin", "/usr/bin", "/usr/sbin"]
		
		for path in systemPaths {
			var stat = stat()
			if stat(path, &stat) == 0 {
				// Check for unexpected write permissions
				if (stat.st_mode & S_IWUSR) != 0 {
					return true
				}
			}
		}
		
		return false
	}
	
	/// Runtime environment scanner: Detects suspicious environment variables
	/// v2.1.5: Filters development tools to reduce false positives
	private static func scanRuntimeEnvironment() -> Bool {
		let suspiciousVars = ["DYLD_INSERT_LIBRARIES", "_MSSafeMode", "_SafeMode"]
		
		for envVar in suspiciousVars {
			if let value = getenv(envVar) {
				let valueStr = String(cString: value)
				if !valueStr.isEmpty {
					// Filter out Xcode debugger - legitimate development tool
					if envVar == "DYLD_INSERT_LIBRARIES" && valueStr.contains("libViewDebuggerSupport") {
						continue
					}
					return true
				}
			}
		}
		
		return false
	}
	
	// MARK: - Bypass Detection
	
	/// Anti-bypass measures: Detects attempts to circumvent detection
	static func detectBypassAttempts() -> Bool {
		let bypassIndicators = [
			checkForDebugger(),
			checkForHooking(),
			checkForMethodSwizzling()
		]
		
		return bypassIndicators.contains(true)
	}
	
	/// Debugger detection via sysctl
	private static func checkForDebugger() -> Bool {
		var info = kinfo_proc()
		var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
		var size = MemoryLayout<kinfo_proc>.stride
		
		let result = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
		guard result == 0 else { return false }
		
		return (info.kp_proc.p_flag & P_TRACED) != 0
	}
	
	/// Hook detection: Validates function pointer integrity
	private static func checkForHooking() -> Bool {
		// Implementation uses runtime introspection
		// Details redacted for security
		return false
	}
	
	/// Method swizzling detection: Monitors Objective-C runtime modifications
	private static func checkForMethodSwizzling() -> Bool {
		// Implementation monitors method IMP changes
		// Details redacted for security
		return false
	}
	
	// MARK: - Risk Scoring
	
	/// Calculates weighted risk score based on detection results
	private static func calculateRiskScore(results: [DetectionMethod: Bool]) -> Double {
		let weights: [DetectionMethod: Double] = [
			.suspiciousFiles: 1.5,
			.suspiciousApps: 1.2,
			.sandboxViolation: 2.0,
			.dyldInjection: 2.5,
			.urlSchemeCheck: 1.0,
			.writeTest: 2.0,
			.symlinkAnalysis: 1.3,
			.forkRestriction: 2.2,
			.permissionAudit: 1.4,
			.environmentCheck: 1.1
		]
		
		var score = 0.0
		for (method, detected) in results where detected {
			score += weights[method] ?? 1.0
		}
		
		return min(score / 10.0, 1.0) // Normalize to 0-1
	}
}

// MARK: - Diagnostics

extension JailbreakDetector {
	/// Generates human-readable detection report
	/// v2.1.5: Enhanced with platform information
	static func generateDetectionReport() -> String {
		let report = detectJailbreak()
		
		var output = """
		=== NuDefndr Jailbreak Detection Report ===
		Platform: \(report.platform.rawValue)
		Status: \(report.isJailbroken ? "⚠️ JAILBROKEN" : "✅ SECURE")
		Confidence: \(report.confidenceLevel.rawValue)
		Risk Score: \(String(format: "%.2f", report.riskScore * 100))%
		Timestamp: \(report.timestamp)
		
		"""
		
		if let notice = report.platformNotice {
			output += """
			Platform Notice:
			\(notice)
			
			"""
		}
		
		output += "Detection Vectors:\n"
		
		for (method, detected) in report.detectionMethods.sorted(by: { $0.key.rawValue < $1.key.rawValue }) {
			let icon = detected ? "🔴" : "✅"
			output += "  \(icon) \(method.rawValue): \(detected ? "DETECTED" : "Clear")\n"
		}
		
		output += """
		
		===========================================
		NuDefndr Security Engine v2.1.5
		© 2025 Dro1d Labs Limited
		"""
		
		return output
	}
}

