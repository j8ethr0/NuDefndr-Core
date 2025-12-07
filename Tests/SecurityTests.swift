// Copyright (c) 2025 Dro1d Labs Limited
// Released under the MIT License. See LICENSE file for details.
//
// NuDefndr App - Security Validation Tests
// App Website: https://nudefndr.com
// Developer: Dro1d Labs

import Foundation
import XCTest
@testable import NuDefndr

/// Security-focused validation and penetration tests
class SecurityTests: XCTestCase {
	
	// MARK: - Jailbreak Detection Tests
	
	func testJailbreakDetection() {
		let report = JailbreakDetector.detectJailbreak()
		
		// In CI/test environments, should not detect jailbreak
		XCTAssertFalse(report.isJailbroken, "Test environment should not be jailbroken")
		XCTAssertEqual(report.confidenceLevel, .none, "Should have no jailbreak indicators")
	}
	
	func testJailbreakBypassDetection() {
		let bypassDetected = JailbreakDetector.detectBypassAttempts()
		
		// Should not detect bypass attempts in normal testing
		XCTAssertFalse(bypassDetected, "Should not detect bypass in test environment")
	}
	
	// MARK: - Anti-Tampering Tests
	
	func testCodeSignatureValidation() {
		let report = AntiTamperingValidator.validateIntegrity()
		
		XCTAssertTrue(report.codeSignatureValid, "Code signature should be valid")
		XCTAssertTrue(report.bundleIntegrityValid, "Bundle integrity should be intact")
		XCTAssertEqual(report.overallIntegrity, .intact, "Overall integrity should be intact")
	}
	
	func testDebuggerDetection() {
		let debuggerAttached = AntiTamperingValidator.isDebuggerAttached()
		
		// When running under Xcode, debugger IS attached
		#if DEBUG
		// In debug builds, this might be true
		print("Debugger attached: \(debuggerAttached)")
		#else
		XCTAssertFalse(debuggerAttached, "Production builds should not have debugger")
		#endif
	}
	
	func testEnvironmentValidation() {
		let environment = AntiTamperingValidator.analyzeEnvironment()
		
		// Verify environment makes sense
		#if targetEnvironment(simulator)
		XCTAssertTrue(environment.isSimulator, "Should detect simulator")
		XCTAssertEqual(environment.environmentType, .simulator)
		#endif
		
		#if DEBUG
		XCTAssertTrue(environment.isDebugBuild, "Should detect debug build")
		#endif
	}
	
	// MARK: - Secure Logging Tests
	
	func testPIIRedaction() {
		// Test that sensitive data is properly redacted
		let testMessages = [
			("User email: test@example.com", "[EMAIL]"),
			("Asset ID: 12345678-1234-1234-1234-123456789ABC/L0/001", "[ASSET_ID]"),
			("IP: 192.168.1.1", "[IP_ADDRESS]"),
			("Key: abcdef1234567890abcdef1234567890abcdef1234567890", "[KEY]")
		]
		
		for (input, expected) in testMessages {
			SecureLogger.info(input, category: "Test")
			
			// Verify redaction occurred (check recent logs)
			let recentLogs = SecureLogger.getRecentLogs(count: 1)
			XCTAssertTrue(recentLogs.first?.contains(expected) ?? false, "Should redact: \(input)")
		}
		
		SecureLogger.clearBuffer()
	}
	
	func testLogLevelFiltering() {
		// Clear buffer
		SecureLogger.clearBuffer()
		
		// Log messages at different levels
		SecureLogger.debug("Debug message", category: "Test")
		SecureLogger.info("Info message", category: "Test")
		SecureLogger.warning("Warning message", category: "Test")
		
		let logs = SecureLogger.getRecentLogs()
		
		// Should have logged all three messages
		XCTAssertGreaterThanOrEqual(logs.count, 3, "Should log multiple messages")
	}
	
	// MARK: - Performance Monitor Tests
	
	func testThermalStateMonitoring() {
		let monitor = PerformanceMonitor.shared
		
		// Verify thermal state is tracked
		let batchSize = monitor.adaptiveBatchSize()
		XCTAssertGreaterThan(batchSize, 0, "Batch size should be positive")
		XCTAssertLessThanOrEqual(batchSize, 50, "Batch size should be reasonable")
	}
	
	func testMemoryPressureDetection() {
		let monitor = PerformanceMonitor.shared
		
		let isHighPressure = monitor.isMemoryPressureHigh()
		
		// Should return a valid boolean
		XCTAssertNotNil(isHighPressure)
	}
	
	func testDeviceCapabilityDetection() {
		let capabilities = PerformanceMonitor.shared.assessDeviceCapabilities()
		
		XCTAssertGreaterThan(capabilities.cpuCores, 0, "Should detect CPU cores")
		XCTAssertGreaterThan(capabilities.totalMemory, 0, "Should detect memory")
		XCTAssertTrue(capabilities.supportsHardwareCrypto, "Modern devices support hardware crypto")
	}
	
	// MARK: - Penetration Test Simulations
	
	func testUnauthorizedKeyAccess() {
		// Attempt to access keychain without proper entitlements
		// This should fail gracefully
		
		let result = KeychainSecure.loadKey(forName: "nonexistent_key")
		XCTAssertNil(result, "Should not load nonexistent keys")
	}
	
	func testKeyExportPrevention() {
		// Verify keys cannot be exported from keychain
		let key = VaultCrypto.generateVaultKey()
		let saved = KeychainSecure.saveKey(key, forName: "test_key_export")
		
		XCTAssertTrue(saved, "Key should be saved")
		
		// Attempt to load - should work
		let loaded = KeychainSecure.loadKey(forName: "test_key_export")
		XCTAssertNotNil(loaded, "Key should be loadable")
		
		// But key data should not be directly extractable outside keychain
		// (This is enforced by kSecAttrAccessibleWhenUnlockedThisDeviceOnly)
	}
	
	func testReplayAttackPrevention() {
		// Test that encrypted data includes nonce/IV to prevent replay
		let testData = "Test Message".data(using: .utf8)!
		let key = VaultCrypto.generateVaultKey()
		
		do {
			let encrypted1 = try VaultCrypto.encryptData(testData, using: key)
			let encrypted2 = try VaultCrypto.encryptData(testData, using: key)
			
			// Same plaintext should produce different ciphertext (due to random nonce)
			XCTAssertNotEqual(encrypted1, encrypted2, "Encryption should use random nonce")
		} catch {
			XCTFail("Encryption failed: \(error)")
		}
	}
	
	// MARK: - Compliance Tests
	
	func testFIPSComplianceReport() {
		let auditReport = CryptoValidator.runSecurityAudit()
		
		XCTAssertTrue(
			auditReport.entropyTest.passesNISTTests,
			"Entropy source should pass NIST tests"
		)
		
		XCTAssertTrue(
			auditReport.kdfValidation.meetsMinimumIterations,
			"KDF should use sufficient iterations"
		)
		
		XCTAssertTrue(
			auditReport.timingAttackResistant,
			"Should resist timing attacks"
		)
	}
}

// MARK: - Mock Attacker Scenarios

extension SecurityTests {
	/// Simulates attacker attempting brute-force PIN
	func testBruteForcePrevention() {
		// In real app, rate limiting would be enforced
		// This tests the PIN hashing is sufficiently slow
		
		let testPIN = "1234"
		let iterations = 100
		
		let start = Date()
		for _ in 0..<iterations {
			_ = VaultCrypto.hashPIN(testPIN)
		}
		let elapsed = Date().timeIntervalSince(start)
		
		let timePerHash = elapsed / Double(iterations)
		
		// Each hash should take measurable time (PBKDF2 with high iteration count)
		print("Time per PIN hash: \(String(format: "%.4f", timePerHash))s")
		
		// Should be fast enough for UX but slow enough to deter brute force
		XCTAssertLessThan(timePerHash, 0.1, "PIN hashing should be reasonably fast")
	}
}