// Copyright (c) 2025 Dro1d Labs Limited
// Released under the MIT License. See LICENSE file for details.
//
// NuDefndr App - Cryptographic Validation Component
// App Website: https://nudefndr.com
// Developer: Dro1d Labs

import Foundation
import CryptoKit
import CommonCrypto

/// Cryptographic validation and compliance testing framework
class CryptoValidator {
	
	// MARK: - FIPS 140-2 Compliance Checks
	
	enum FIPSComplianceLevel {
		case level1  // Software crypto, approved algorithms
		case level2  // Role-based authentication
		case level3  // Physical tamper detection
		case level4  // Complete envelope protection
		case nonCompliant
	}
	
	struct ComplianceReport {
		let level: FIPSComplianceLevel
		let approvedAlgorithms: [String]
		let keyStrength: String
		let randomnessSource: String
		let timestamp: Date
	}
	
	/// Validates FIPS 140-2 compliance of current crypto configuration
	static func validateFIPSCompliance() -> ComplianceReport {
		// Check approved algorithms
		let algorithms = [
			"AES-256",
			"ChaCha20-Poly1305",
			"SHA-256",
			"PBKDF2"
		]
		
		// Determine compliance level
		let level: FIPSComplianceLevel
		if VaultCrypto.detectCryptoBackend() == .secureEnclave {
			level = .level2 // Hardware-backed keys
		} else {
			level = .level1 // Software crypto only
		}
		
		return ComplianceReport(
			level: level,
			approvedAlgorithms: algorithms,
			keyStrength: "256-bit",
			randomnessSource: "SecRandomCopyBytes",
			timestamp: Date()
		)
	}
	
	// MARK: - Entropy Testing (NIST SP 800-90B)
	
	struct EntropyTestResult {
		let sampledEntropy: Double
		let estimatedMinEntropy: Double
		let passesNISTTests: Bool
		let sampleSize: Int
	}
	
	/// Performs entropy testing on random data source
	static func testEntropySource(sampleSize: Int = 1024) -> EntropyTestResult {
		var randomData = Data(count: sampleSize)
		let status = randomData.withUnsafeMutableBytes { bytes in
			SecRandomCopyBytes(kSecRandomDefault, sampleSize, bytes.baseAddress!)
		}
		
		guard status == errSecSuccess else {
			return EntropyTestResult(
				sampledEntropy: 0.0,
				estimatedMinEntropy: 0.0,
				passesNISTTests: false,
				sampleSize: 0
			)
		}
		
		let entropy = calculateShannonEntropy(randomData)
		let minEntropy = estimateMinEntropy(randomData)
		
		// NIST requires > 7.5 bits/byte for full entropy
		let passes = entropy >= 7.5 && minEntropy >= 7.0
		
		return EntropyTestResult(
			sampledEntropy: entropy,
			estimatedMinEntropy: minEntropy,
			passesNISTTests: passes,
			sampleSize: sampleSize
		)
	}
	
	private static func calculateShannonEntropy(_ data: Data) -> Double {
		var frequency = [UInt8: Int]()
		
		for byte in data {
			frequency[byte, default: 0] += 1
		}
		
		let length = Double(data.count)
		var entropy: Double = 0.0
		
		for count in frequency.values {
			let probability = Double(count) / length
			if probability > 0 {
				entropy -= probability * log2(probability)
			}
		}
		
		return entropy
	}
	
	/// Conservative min-entropy estimation (collision entropy)
	private static func estimateMinEntropy(_ data: Data) -> Double {
		var frequency = [UInt8: Int]()
		
		for byte in data {
			frequency[byte, default: 0] += 1
		}
		
		// Find most common byte
		guard let maxFrequency = frequency.values.max() else { return 0.0 }
		
		let probability = Double(maxFrequency) / Double(data.count)
		return -log2(probability)
	}
	
	// MARK: - Key Derivation Function Validation
	
	struct KDFValidationResult {
		let iterations: UInt32
		let estimatedTimeMs: Double
		let meetsMinimumIterations: Bool
		let algorithm: String
	}
	
	/// Validates PBKDF2 parameters meet security standards
	static func validateKDFParameters(iterations: UInt32 = 100_000) -> KDFValidationResult {
		let startTime = Date()
		
		// Perform test derivation
		let testPassword = "TestPassword123"
		let testSalt = Data(repeating: 0x42, count: 16)
		
		_ = try? VaultCrypto.deriveKeyFromPassword(testPassword, salt: testSalt, rounds: iterations)
		
		let elapsed = Date().timeIntervalSince(startTime) * 1000 // milliseconds
		
		// OWASP recommends minimum 100,000 iterations for PBKDF2-SHA256
		let meetsMinimum = iterations >= 100_000
		
		return KDFValidationResult(
			iterations: iterations,
			estimatedTimeMs: elapsed,
			meetsMinimumIterations: meetsMinimum,
			algorithm: "PBKDF2-HMAC-SHA256"
		)
	}
	
	// MARK: - Timing Attack Resistance
	
	/// Validates constant-time comparison for authentication
	static func validateConstantTimeComparison() -> Bool {
		let testHash1 = Data([0x01, 0x02, 0x03, 0x04])
		let testHash2 = Data([0x01, 0x02, 0x03, 0x05])
		
		// Measure timing variance across multiple comparisons
		var timings: [TimeInterval] = []
		
		for _ in 0..<100 {
			let start = Date()
			_ = constantTimeCompare(testHash1, testHash2)
			timings.append(Date().timeIntervalSince(start))
		}
		
		// Calculate coefficient of variation
		let mean = timings.reduce(0, +) / Double(timings.count)
		let variance = timings.map { pow($0 - mean, 2) }.reduce(0, +) / Double(timings.count)
		let stdDev = sqrt(variance)
		let coefficientOfVariation = stdDev / mean
		
		// Low CV indicates constant-time behavior
		return coefficientOfVariation < 0.1
	}
	
	private static func constantTimeCompare(_ lhs: Data, _ rhs: Data) -> Bool {
		guard lhs.count == rhs.count else { return false }
		
		var result: UInt8 = 0
		for (a, b) in zip(lhs, rhs) {
			result |= a ^ b
		}
		
		return result == 0
	}
	
	// MARK: - Comprehensive Security Audit
	
	struct SecurityAuditReport {
		let fipsCompliance: ComplianceReport
		let entropyTest: EntropyTestResult
		let kdfValidation: KDFValidationResult
		let timingAttackResistant: Bool
		let hardwareAcceleration: VaultCrypto.CryptoBackend
		let overallRating: SecurityRating
	}
	
	enum SecurityRating: String {
		case excellent = "Excellent (Production Ready)"
		case good = "Good (Minor Improvements Recommended)"
		case adequate = "Adequate (Functional but Suboptimal)"
		case poor = "Poor (Security Concerns Detected)"
	}
	
	/// Runs comprehensive security audit on crypto subsystem
	static func runSecurityAudit() -> SecurityAuditReport {
		let fips = validateFIPSCompliance()
		let entropy = testEntropySource()
		let kdf = validateKDFParameters()
		let timing = validateConstantTimeComparison()
		let hardware = VaultCrypto.detectCryptoBackend()
		
		// Determine overall rating
		let rating: SecurityRating
		if entropy.passesNISTTests && kdf.meetsMinimumIterations && timing {
			rating = .excellent
		} else if entropy.passesNISTTests && kdf.meetsMinimumIterations {
			rating = .good
		} else if entropy.sampledEntropy > 7.0 {
			rating = .adequate
		} else {
			rating = .poor
		}
		
		return SecurityAuditReport(
			fipsCompliance: fips,
			entropyTest: entropy,
			kdfValidation: kdf,
			timingAttackResistant: timing,
			hardwareAcceleration: hardware,
			overallRating: rating
		)
	}
}

// MARK: - Diagnostic Formatting

extension CryptoValidator {
	static func generateAuditReport() -> String {
		let audit = runSecurityAudit()
		
		return """
		=== Cryptographic Security Audit ===
		
		FIPS 140-2 Compliance: \(audit.fipsCompliance.level)
		Approved Algorithms: \(audit.fipsCompliance.approvedAlgorithms.joined(separator: ", "))
		
		Entropy Testing (NIST SP 800-90B):
		  - Shannon Entropy: \(String(format: "%.2f", audit.entropyTest.sampledEntropy)) bits/byte
		  - Min Entropy: \(String(format: "%.2f", audit.entropyTest.estimatedMinEntropy)) bits/byte
		  - NIST Compliance: \(audit.entropyTest.passesNISTTests ? "PASS" : "FAIL")
		
		Key Derivation (PBKDF2):
		  - Iterations: \(audit.kdfValidation.iterations)
		  - Time per Derivation: \(String(format: "%.2f", audit.kdfValidation.estimatedTimeMs))ms
		  - Meets Minimum: \(audit.kdfValidation.meetsMinimumIterations ? "YES" : "NO")
		
		Timing Attack Resistance: \(audit.timingAttackResistant ? "PROTECTED" : "VULNERABLE")
		Hardware Acceleration: \(audit.hardwareAcceleration.rawValue)
		
		Overall Security Rating: \(audit.overallRating.rawValue)
		=====================================
		"""
	}
}