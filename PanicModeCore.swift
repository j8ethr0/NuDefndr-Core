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

// Advanced Panic Mode Features

extension PanicModeValidator {
  
  /// Multi-PIN validation with decoy detection
  static func validateAdvancedPIN(_ pin: String, primaryHash: String, decoyHash: String, duressHash: String?) -> VaultAccessMode {
	  let enteredHash = VaultCrypto.hashPIN(pin)
	  
	  if enteredHash.hash == Data(primaryHash.utf8) {
		  return .primary
	  } else if enteredHash.hash == Data(decoyHash.utf8) {
		  return .decoy
	  } else if let duress = duressHash, enteredHash.hash == Data(duress.utf8) {
		  return .duress
	  }
	  
	  return .denied
  }
  
  /// Emergency vault wipe protocol
  static func initiateEmergencyWipe(confirmationCode: String) -> WipeResult {
	  guard confirmationCode == "EMERGENCY_WIPE_CONFIRMED" else {
		  return .denied
	  }
	  
	  // emergency wipe logic
	  return .initiated
  }
}
 

enum VaultAccessMode: String, CaseIterable {
  case primary = "Primary Vault"
  case decoy = "Decoy Vault" 
  case duress = "Duress Mode"
  case denied = "Access Denied"
  
  var securityLevel: SecurityLevel {
	  switch self {
	  case .primary: return .maximum
	  case .decoy: return .enhanced
	  case .duress: return .standard
	  case .denied: return .standard
	  }
  }
}

enum WipeResult {
  case initiated
  case completed
  case denied
  case failed(Error)
}

// Panic Mode Configuration

struct PanicModeConfig {
  let enableDecoyVault: Bool
  let enableDuressMode: Bool
  let emergencyWipeEnabled: Bool
  let maxFailedAttempts: Int
  let lockoutDuration: TimeInterval
  
  static let `default` = PanicModeConfig(
	  enableDecoyVault: true,
	  enableDuressMode: false,
	  emergencyWipeEnabled: false,
	  maxFailedAttempts: 5,
	  lockoutDuration: 300 // 5 minutes
  )
}
