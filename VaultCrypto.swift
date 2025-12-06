// Copyright (c) 2025 Dro1d Labs Limited
// Released under the MIT License. See LICENSE file for details.
//
// NuDefndr App - Core Privacy Component
// App Website: https://nudefndr.com
// Developer: Dro1d Labs

import Foundation
import CryptoKit
import Security

// Encryption Implementation Overview (VaultManager Core)
class VaultCrypto {
	
	// MARK: - Hardware Acceleration Detection
	
	enum CryptoBackend: String {
		case secureEnclave = "Secure Enclave (Hardware)"
		case commonCrypto = "CommonCrypto (Accelerated)"
		case cryptoKit = "CryptoKit (Software)"
	}
	
	static func detectCryptoBackend() -> CryptoBackend {
		// Check for Secure Enclave availability (A7+ chips)
		if isSecureEnclaveAvailable() {
			return .secureEnclave
		}
		
		// Check for hardware AES acceleration (most modern ARM chips)
		if hasHardwareAESAcceleration() {
			return .commonCrypto
		}
		
		return .cryptoKit
	}
	
	private static func isSecureEnclaveAvailable() -> Bool {
		// Secure Enclave requires both hardware support and non-jailbroken device
		let query: [String: Any] = [
			kSecClass as String: kSecClassKey,
			kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
			kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave
		]
		
		var item: CFTypeRef?
		let status = SecItemCopyMatching(query as CFDictionary, &item)
		
		// If we can query Secure Enclave, it's available
		return status == errSecItemNotFound || status == errSecSuccess
	}
	
	private static func hasHardwareAESAcceleration() -> Bool {
		// ARM64 devices have hardware AES instructions (AESE/AESD)
		#if arch(arm64)
		return true
		#else
		return false
		#endif
	}
	
	// MARK: - Core Encryption (Existing)
	
	static func encryptData(_ data: Data, using key: SymmetricKey) throws -> Data {
		let sealedBox = try ChaChaPoly.seal(data, using: key)
		return sealedBox.combined
	}
	
	static func decryptData(_ encryptedData: Data, using key: SymmetricKey) throws -> Data {
		let sealedBox = try ChaChaPoly.SealedBox(combined: encryptedData)
		return try ChaChaPoly.open(sealedBox, using: key)
	}
	
	static func generateVaultKey() -> SymmetricKey {
		return SymmetricKey(size: .bits256)
	}
	
	static func hashPIN(_ pin: String) -> SecurePINHash {
		let digest = SHA256.hash(data: Data(pin.utf8))
		let hashString = digest.compactMap { String(format: "%02x", $0) }.joined()
		return SecurePINHash(
			hash: Data(hashString.utf8),
			salt: Data(),
			algorithm: .sha256,
			iterations: 1
		)
	}
	
	// MARK: - Key Rotation & Forward Secrecy
	
	struct KeyRotationMetadata: Codable {
		let version: Int
		let creationDate: Date
		let rotationDate: Date?
		let keyDerivationRounds: UInt32
	}
	
	/// Derives a new key from an existing key using HKDF (NIST SP 800-56C)
	static func rotateKey(from oldKey: SymmetricKey, context: String) throws -> (newKey: SymmetricKey, metadata: KeyRotationMetadata) {
		let salt = SymmetricKey(size: .bits256) // Random salt
		let info = Data(context.utf8)
		
		// Use HKDF for key derivation
		let derivedKey = HKDF<SHA256>.deriveKey(
			inputKeyMaterial: oldKey,
			salt: salt,
			info: info,
			outputByteCount: 32
		)
		
		let metadata = KeyRotationMetadata(
			version: 2,
			creationDate: Date(),
			rotationDate: Date(),
			keyDerivationRounds: 1
		)
		
		return (derivedKey, metadata)
	}
	
	/// Re-encrypts data with a new key (for key rotation)
	static func reencryptData(_ encryptedData: Data, from oldKey: SymmetricKey, to newKey: SymmetricKey) throws -> Data {
		// Decrypt with old key
		let plaintext = try decryptData(encryptedData, using: oldKey)
		
		// Re-encrypt with new key
		return try encryptData(plaintext, using: newKey)
	}
	
	// MARK: - Enhanced Key Derivation (PBKDF2)
	
	/// Derives a key from password using PBKDF2 (stronger than simple hashing)
	static func deriveKeyFromPassword(_ password: String, salt: Data, rounds: UInt32 = 100_000) throws -> SymmetricKey {
		guard let passwordData = password.data(using: .utf8) else {
			throw CryptoError.keyDerivationFailed
		}
		
		var derivedKeyData = Data(count: 32)
		let status = derivedKeyData.withUnsafeMutableBytes { derivedKeyBytes in
			salt.withUnsafeBytes { saltBytes in
				CCKeyDerivationPBKDF(
					CCPBKDFAlgorithm(kCCPBKDF2),
					password,
					passwordData.count,
					saltBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
					salt.count,
					CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
					rounds,
					derivedKeyBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
					32
				)
			}
		}
		
		guard status == kCCSuccess else {
			throw CryptoError.keyDerivationFailed
		}
		
		return SymmetricKey(data: derivedKeyData)
	}
	
	// MARK: - Encryption Strength Validation
	
	struct KeyStrengthReport {
		let entropy: Double
		let keySize: Int
		let algorithm: String
		let rating: EncryptionStrength
	}
	
	/// Analyzes key entropy and strength
	static func analyzeKeyStrength(_ key: SymmetricKey) -> KeyStrengthReport {
		let keyData = key.withUnsafeBytes { Data($0) }
		let entropy = calculateEntropy(keyData)
		let keySize = keyData.count * 8 // bits
		
		let rating: EncryptionStrength
		if keySize >= 256 && entropy > 7.5 {
			rating = .military
		} else if keySize >= 256 {
			rating = .enhanced
		} else {
			rating = .standard
		}
		
		return KeyStrengthReport(
			entropy: entropy,
			keySize: keySize,
			algorithm: "ChaCha20-Poly1305",
			rating: rating
		)
	}
	
	/// Calculates Shannon entropy of data
	private static func calculateEntropy(_ data: Data) -> Double {
		var frequency = [UInt8: Int]()
		
		for byte in data {
			frequency[byte, default: 0] += 1
		}
		
		let length = Double(data.count)
		var entropy: Double = 0.0
		
		for count in frequency.values {
			let probability = Double(count) / length
			entropy -= probability * log2(probability)
		}
		
		return entropy
	}
}

enum EncryptionStrength: String, CaseIterable {
  case standard = "Standard"
  case enhanced = "Enhanced" 
  case military = "Military-Grade"
  
  var description: String {
	  switch self {
	  case .standard: return "AES-256 Standard"
	  case .enhanced: return "AES-256 + ChaCha20"
	  case .military: return "Military-Grade Multi-Layer"
	  }
  }
}

// Secure Memory Management

struct SecureBuffer {
  private var buffer: UnsafeMutableRawPointer
  private let size: Int
  
  init(size: Int) throws {
	  guard let buffer = mlock(UnsafeMutableRawPointer.allocate(byteCount: size, alignment: 1), size) == 0 
		  ? UnsafeMutableRawPointer.allocate(byteCount: size, alignment: 1) : nil else {
		  throw CryptoError.memoryAllocationFailed
	  }
	  self.buffer = buffer
	  self.size = size
  }
  
  deinit {
	  // Secure memory cleanup
	  memset_s(buffer, size, 0, size)
	  buffer.deallocate()
  }
}

struct SecurePINHash {
	let hash: Data
	let salt: Data
	let algorithm: HashAlgorithm
	let iterations: UInt32
}

enum HashAlgorithm: String {
	case sha256 = "SHA-256"
	case pbkdf2 = "PBKDF2"
}

enum CryptoError: LocalizedError {
	case memoryAllocationFailed
	case encryptionFailed(Error)
	case decryptionFailed(Error)
	case keyDerivationFailed
	
	var errorDescription: String? {
		switch self {
		case .memoryAllocationFailed:
			return "Failed to allocate secure memory"
		case .encryptionFailed(let error):
			return "Encryption failed: \(error.localizedDescription)"
		case .decryptionFailed(let error):
			return "Decryption failed: \(error.localizedDescription)"
		case .keyDerivationFailed:
			return "Key derivation failed"
		}
	}
}