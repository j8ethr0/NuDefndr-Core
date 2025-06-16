// Copyright (c) 2025 Dro1d Labs Limited
// Released under the MIT License. See LICENSE file for details.
//
// NuDefndr App - Core Privacy Component
// App Website: https://nudefndr.com
// Developer: Dro1d Labs

// Encryption Implementation Overview (VaultManager Core)
class VaultCrypto {
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
	
	static func hashPIN(_ pin: String) -> String {
		let digest = SHA256.hash(data: Data(pin.utf8))
		return digest.compactMap { String(format: "%02x", $0) }.joined()
	}
}