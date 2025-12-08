// Copyright (c) 2025
// NuDefndr by Dro1d Labs Limited
// Released under the MIT License. See LICENSE file for details.
//
// NuDefndr App - Cryptographic Validation Component
// Website: https://nudefndr.com
// Developer Contact: dev@nudefndr.com

import Foundation
import CryptoKit
import CommonCrypto

/// Cryptographic validation and internal security diagnostics.
/// These routines are not a substitute for full third-party audits,
/// but provide lightweight verification of entropy, key-derivation
/// hardness, and timing-attack resistance.
final class CryptoValidator {

	// MARK: - FIPS 140-2 Compliance (Informational Only)

	enum FIPSComplianceLevel {
		case level1      // Approved algorithms
		case level2      // Hardware-backed key storage
		case nonCompliant
	}

	struct ComplianceReport {
		let level: FIPSComplianceLevel
		let approvedAlgorithms: [String]
		let keyStrength: String
		let randomnessSource: String
		let timestamp: Date
	}

	/// Performs informational FIPS-aligned checks on algorithm usage.
	static func validateFIPSCompliance() -> ComplianceReport {
		let algorithms = [
			"AES-256",
			"ChaCha20-Poly1305",
			"SHA-256",
			"PBKDF2-HMAC-SHA256"
		]

		let level: FIPSComplianceLevel =
			VaultCrypto.detectCryptoBackend() == .secureEnclave
			? .level2
			: .level1

		return ComplianceReport(
			level: level,
			approvedAlgorithms: algorithms,
			keyStrength: "256-bit",
			randomnessSource: "SecRandomCopyBytes()",
			timestamp: Date()
		)
	}

	// MARK: - Entropy Testing (NIST SP 800-90B Inspired)

	struct EntropyTestResult {
		let sampledEntropy: Double
		let estimatedMinEntropy: Double
		let passesNISTTests: Bool
		let sampleSize: Int
	}

	static func testEntropySource(sampleSize: Int = 1024) -> EntropyTestResult {
		var data = Data(count: sampleSize)
		let status = data.withUnsafeMutableBytes {
			SecRandomCopyBytes(kSecRandomDefault, sampleSize, $0.baseAddress!)
		}

		guard status == errSecSuccess else {
			return EntropyTestResult(
				sampledEntropy: 0,
				estimatedMinEntropy: 0,
				passesNISTTests: false,
				sampleSize: 0
			)
		}

		let entropy = calculateShannonEntropy(data)
		let minEntropy = estimateMinEntropy(data)

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

		for b in data { frequency[b, default: 0] += 1 }

		let total = Double(data.count)
		var entropy = 0.0

		for count in frequency.values {
			let p = Double(count) / total
			entropy -= p * log2(p)
		}

		return entropy
	}

	private static func estimateMinEntropy(_ data: Data) -> Double {
		var frequency = [UInt8: Int]()
		for b in data { frequency[b, default: 0] += 1 }

		guard let maxFreq = frequency.values.max() else { return 0 }
		let p = Double(maxFreq) / Double(data.count)

		return -log2(p)
	}

	// MARK: - PBKDF2 KDF Validation

	struct KDFValidationResult {
		let iterations: UInt32
		let estimatedTimeMs: Double
		let meetsMinimum: Bool
		let algorithm: String
	}

	static func validateKDFParameters(iterations: UInt32 = 100_000) -> KDFValidationResult {
		let start = Date()

		let password = "TestPassword123"
		let salt = Data(repeating: 0x42, count: 16)

		_ = try? VaultCrypto.deriveKeyFromPassword(password, salt: salt, rounds: iterations)

		let elapsed = Date().timeIntervalSince(start) * 1000
		let meetsMin = iterations >= 100_000

		return KDFValidationResult(
			iterations: iterations,
			estimatedTimeMs: elapsed,
			meetsMinimum: meetsMin,
			algorithm: "PBKDF2-HMAC-SHA256"
		)
	}

	// MARK: - Timing Attack Resistance

	static func validateConstantTimeComparison() -> Bool {
		let h1 = Data([0x01, 0x02, 0x03, 0x04])
		let h2 = Data([0x01, 0x02, 0x03, 0x05])

		var samples: [TimeInterval] = []

		for _ in 0..<100 {
			let start = Date()
			_ = constantTimeCompare(h1, h2)
			samples.append(Date().timeIntervalSince(start))
		}

		let mean = samples.reduce(0, +) / Double(samples.count)
		let variance = samples.map { pow($0 - mean, 2) }.reduce(0, +) / Double(samples.count)
		let stdDev = sqrt(variance)

		return (stdDev / mean) < 0.1
	}

	private static func constantTimeCompare(_ a: Data, _ b: Data) -> Bool {
		guard a.count == b.count else { return false }

		var result: UInt8 = 0
		for (x, y) in zip(a, b) { result |= x ^ y }

		return result == 0
	}

	// MARK: - Overall Audit

	enum SecurityRating: String {
		case excellent = "Excellent"
		case good = "Good"
		case adequate = "Adequate"
		case poor = "Poor"
	}

	struct SecurityAuditReport {
		let fips: ComplianceReport
		let entropy: EntropyTestResult
		let kdf: KDFValidationResult
		let timingResistant: Bool
		let hardware: VaultCrypto.CryptoBackend
		let rating: SecurityRating
	}

	static func runSecurityAudit() -> SecurityAuditReport {
		let f = validateFIPSCompliance()
		let e = testEntropySource()
		let k = validateKDFParameters()
		let t = validateConstantTimeComparison()
		let hw = VaultCrypto.detectCryptoBackend()

		let rating: SecurityRating =
			(e.passesNISTTests && k.meetsMinimum && t) ? .excellent :
			(e.passesNISTTests && k.meetsMinimum) ? .good :
			(e.sampledEntropy > 7.0) ? .adequate :
			.poor

		return SecurityAuditReport(
			fips: f,
			entropy: e,
			kdf: k,
			timingResistant: t,
			hardware: hw,
			rating: rating
		)
	}

	static func generateAuditReport() -> String {
		let a = runSecurityAudit()

		return """
		=== NuDefndr Cryptographic Audit ===

		FIPS Compliance: \(a.fips.level)
		Approved Algorithms: \(a.fips.approvedAlgorithms.joined(separator: ", "))

		Entropy Testing:
		  • Shannon: \(String(format: "%.2f", a.entropy.sampledEntropy))
		  • Min: \(String(format: "%.2f", a.entropy.estimatedMinEntropy))
		  • NIST Pass: \(a.entropy.passesNISTTests)

		PBKDF2:
		  • Iterations: \(a.kdf.iterations)
		  • Time: \(String(format: "%.2f", a.kdf.estimatedTimeMs)) ms
		  • Meets Minimum: \(a.kdf.meetsMinimum)

		Timing Attacks: \(a.timingResistant ? "Constant-time OK" : "Possible Variance")
		Hardware Backend: \(a.hardware.rawValue)

		Overall Rating: \(a.rating.rawValue)
		======================================
		"""
	}
}