// PanicModeConfig.swift
// Secure local configuration for PanicModeEngine

import Foundation
import CryptoKit

public struct PanicModeConfig {

	// Primary unlock PIN (hashed)
	public let primaryPin: String = "HASHED_PRIMARY_PIN"

	// Duress PIN
	public let duressPin: String = "HASHED_DURESS_PIN"

	// Decoy PIN
	public let decoyPin: String = "HASHED_DECOY_PIN"

	// Future: add configuration flags or behaviour switches here
	public init() {}
}