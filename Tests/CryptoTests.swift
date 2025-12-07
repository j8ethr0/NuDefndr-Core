// Copyright (c) 2025 Dro1d Labs Limited
// Released under the MIT License. See LICENSE file for details.
//
// NuDefndr App - Cryptographic Unit Tests
// App Website: https://nudefndr.com
// Developer: Dro1d Labs

import Foundation
import XCTest
import CryptoKit
@testable import NuDefndr

/// Comprehensive cryptographic unit tests
class CryptoTests: XCTestCase {
	
	// MARK: - Encryption/Decryption Tests
	
	func testBasicEncryptionDecryption() {
		let testData = "Hello, World!".data(using: .utf8)!
		let key = VaultCrypto.generateVaultKey()
		
		do {
			let encrypted = try VaultCrypto.encryptData(testData, using: key)
			XCTAssertNotEqual(encrypted, testData, "Encrypted data should differ from plaintext")
			
			let decrypted = try VaultCrypto.decryptData(encrypted, using: key)
			XCTAssertEqual(decrypted, testData, "Decrypted data should match original")
		} catch {
			XCTFail("Encryption/Decryption failed: \(error)")
		}
	}
	
	func testEncryptionWithDifferentKeys() {
		let testData = "Secret Message".data(using: .utf8)!
		let key1 = VaultCrypto.generateVaultKey()
		let key2 = VaultCrypto.generateVaultKey()
		
		do {
			let encrypted = try VaultCrypto.encryptData(testData, using: key1)
			
			// Attempting to decrypt with wrong key should fail
			XCTAssertThrowsError(try VaultCrypto.decryptData(encrypted, using: key2)) {
				error in
				// Expected behavior
			}
		} catch {
			XCTFail("Test setup failed: \(error)")
		}
	}
	
	func testLargeDataEncryption() {
		let largeData = Data(repeating: 0x42, count: 10 * 1024 * 1024) // 10MB
		let key = VaultCrypto.generateVaultKey()
		
		do {
			let encrypted = try VaultCrypto.encryptData(largeData, using: key)
			let decrypted = try VaultCrypto.decryptData(encrypted, using: key)
			
			XCTAssertEqual(decrypted, largeData, "Large data should decrypt correctly")
		} catch {
			XCTFail("Large data encryption failed: \(error)")
		}
	}
	
	// MARK: - Key Derivation Tests
	
	func testKeyDerivationConsistency() {
		let password = "TestPassword123!"
		let salt = Data(repeating: 0x01, count: 16)
		
		do {
			let key1 = try VaultCrypto.deriveKeyFromPassword(password, salt: salt, rounds: 10000)
			let key2 = try VaultCrypto.deriveKeyFromPassword(password, salt: salt, rounds: 10000)
			
			XCTAssertEqual(
				key1.withUnsafeBytes { Data($0) },
				key2.withUnsafeBytes { Data($0) },
				"Same password and salt should produce same key"
			)
		} catch {
			XCTFail("Key derivation failed: \(error)")
		}
	}
	
	func testKeyDerivationDifferentPasswords() {
		let salt = Data(repeating: 0x01, count: 16)
		
		do {
			let key1 = try VaultCrypto.deriveKeyFromPassword("Password1", salt: salt, rounds: 10000)
			let key2 = try VaultCrypto.deriveKeyFromPassword("Password2", salt: salt, rounds: 10000)
			
			XCTAssertNotEqual(
				key1.withUnsafeBytes { Data($0) },
				key2.withUnsafeBytes { Data($0) },
				"Different passwords should produce different keys"
			)
		} catch {
			XCTFail("Key derivation failed: \(error)")
		}
	}
	
	// MARK: - Key Rotation Tests
	
	func testKeyRotation() {
		let testData = "Sensitive Data".data(using: .utf8)!
		let oldKey = VaultCrypto.generateVaultKey()
		
		do {
			// Encrypt with old key
			let encrypted = try VaultCrypto.encryptData(testData, using: oldKey)
			
			// Rotate key
			let (newKey, metadata) = try VaultCrypto.rotateKey(from: oldKey, context: "vault_rotation")
			
			// Re-encrypt with new key
			let reencrypted = try VaultCrypto.reencryptData(encrypted, from: oldKey, to: newKey)
			
			// Verify data can be decrypted with new key
			let decrypted = try VaultCrypto.decryptData(reencrypted, using: newKey)
			XCTAssertEqual(decrypted, testData, "Data should survive key rotation")
			
			XCTAssertEqual(metadata.version, 2, "Metadata version should be 2")
		} catch {
			XCTFail("Key rotation failed: \(error)")
		}
	}
	
	// MARK: - Entropy Tests
	
	func testKeyEntropyValidation() {
		let key = VaultCrypto.generateVaultKey()
		let report = VaultCrypto.analyzeKeyStrength(key)
		
		XCTAssertEqual(report.keySize, 256, "Key size should be 256 bits")
		XCTAssertGreaterThan(report.entropy, 7.0, "Entropy should be high for cryptographic keys")
		XCTAssertEqual(report.rating, .military, "256-bit keys should be rated as military-grade")
	}
	
	func testWeakKeyDetection() {
		// Create a weak key (low entropy)
		let weakKeyData = Data(repeating: 0x00, count: 32)
		let weakKey = SymmetricKey(data: weakKeyData)
		
		let report = VaultCrypto.analyzeKeyStrength(weakKey)
		
		XCTAssertEqual(report.entropy, 0.0, "All-zero key has zero entropy")
		XCTAssertNotEqual(report.rating, .military, "Weak keys should not be rated military-grade")
	}
	
	// MARK: - FIPS Compliance Tests
	
	func testFIPSComplianceValidation() {
		let report = CryptoValidator.validateFIPSCompliance()
		
		XCTAssertTrue(
			report.approvedAlgorithms.contains("AES-256"),
			"Should use FIPS-approved AES-256"
		)
		XCTAssertTrue(
			report.approvedAlgorithms.contains("SHA-256"),
			"Should use FIPS-approved SHA-256"
		)
		XCTAssertEqual(report.keyStrength, "256-bit", "Should use 256-bit keys")
	}
	
	func testEntropySourceQuality() {
		let result = CryptoValidator.testEntropySource(sampleSize: 1024)
		
		XCTAssertGreaterThan(result.sampledEntropy, 7.5, "Entropy source should provide high-quality randomness")
		XCTAssertTrue(result.passesNISTTests, "Entropy source should pass NIST tests")
	}
	
	// MARK: - Timing Attack Tests
	
	func testConstantTimeComparison() {
		let result = CryptoValidator.validateConstantTimeComparison()
		
		XCTAssertTrue(result, "PIN comparison should be constant-time")
	}
	
	// MARK: - Edge Cases
	
	func testEmptyDataEncryption() {
		let emptyData = Data()
		let key = VaultCrypto.generateVaultKey()
		
		do {
			let encrypted = try VaultCrypto.encryptData(emptyData, using: key)
			let decrypted = try VaultCrypto.decryptData(encrypted, using: key)
			
			XCTAssertEqual(decrypted, emptyData, "Empty data should encrypt/decrypt correctly")
		} catch {
			XCTFail("Empty data encryption failed: \(error)")
		}
	}
	
	func testCorruptedDataDecryption() {
		let testData = "Test Data".data(using: .utf8)!
		let key = VaultCrypto.generateVaultKey()
		
		do {
			var encrypted = try VaultCrypto.encryptData(testData, using: key)
			
			// Corrupt a byte
			encrypted[0] ^= 0xFF
			
			// Should fail to decrypt
			XCTAssertThrowsError(try VaultCrypto.decryptData(encrypted, using: key)) {
				error in
				// Expected - authentication tag will fail
			}
		} catch {
			XCTFail("Test setup failed: \(error)")
		}
	}
}

// MARK: - Test Utilities

extension CryptoTests {
	/// Helper to measure encryption throughput
	func measureEncryptionThroughput(dataSize: Int, iterations: Int = 100) -> Double {
		let testData = Data(repeating: 0x42, count: dataSize)
		let key = VaultCrypto.generateVaultKey()
		
		let start = Date()
		
		for _ in 0..<iterations {
			_ = try? VaultCrypto.encryptData(testData, using: key)
		}
		
		let elapsed = Date().timeIntervalSince(start)
		let totalBytes = Double(dataSize * iterations)
		let bytesPerSecond = totalBytes / elapsed
		
		return bytesPerSecond / (1024 * 1024) // MB/s
	}
	
	func testEncryptionThroughput() {
		let throughput = measureEncryptionThroughput(dataSize: 1024 * 1024, iterations: 10)
		
		print("Encryption throughput: \(String(format: "%.2f", throughput)) MB/s")
		
		// Sanity check - should be at least 10 MB/s on modern hardware
		XCTAssertGreaterThan(throughput, 10.0, "Encryption throughput should be reasonable")
	}
}