// Copyright (c) 2025 Dro1d Labs Limited
// Released under the MIT License. See LICENSE file for details.
//
// NuDefndr App - Core Privacy Component
// App Website: https://nudefndr.com
// Developer: Dro1d Labs

// Panic Mode basic Architecturee
enum VaultRoot: String {
	case primary = "SecureVault"
	case decoy = "SecureVaultDecoy"
	
	var keychainName: String {
		switch self {
		case .primary: return "com.nudefndr.vaultKey"
		case .decoy: return "com.nudefndr.vaultKey.decoy"
		}
	}
}

class PanicModeValidator {
	static func validatePIN(_ pin: String, against storedHash: String) -> VaultRoot {
		let enteredHash = VaultCrypto.hashPIN(pin)
		return enteredHash == storedHash ? .decoy : .primary
	}
}