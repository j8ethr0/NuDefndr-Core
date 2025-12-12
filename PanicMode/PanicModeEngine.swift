// Copyright (c) 2025 Dro1d Labs Limited
// Released under the MIT License. See LICENSE file for details.
//
// NuDefndr App - Panic Mode Engine
// App Website: https://nudefndr.com
// Developer: Dro1d Labs

import Foundation
import CryptoKit

/// Dual-vault panic mode system for emergency concealment
/// Provides plausible deniability under coercion scenarios
public class PanicModeEngine {
    
    // MARK: - Singleton
    
    public static let shared = PanicModeEngine()
    
    private var isActive: Bool = false
    private var currentVaultMode: VaultMode = .primary
    
    private init() {
        loadPanicConfiguration()
    }
    
    // MARK: - Vault Mode
    
    public enum VaultMode: String {
        case primary = "Primary Vault"
        case decoy = "Decoy Vault"
    }
    
    public var activeVaultMode: VaultMode {
        return currentVaultMode
    }
    
    // MARK: - Panic PIN Configuration
    
    public struct PanicConfiguration {
        let panicPINEnabled: Bool
        let panicPINHash: Data?
        let decoyVaultPopulated: Bool
        let quickExitEnabled: Bool
        
        public static let disabled = PanicConfiguration(
            panicPINEnabled: false,
            panicPINHash: nil,
            decoyVaultPopulated: false,
            quickExitEnabled: false
        )
    }
    
    private var configuration: PanicConfiguration = .disabled
    
    // MARK: - Setup & Configuration
    
    public func configurePanicMode(panicPIN: String) -> Bool {
        // Production implementation:
        // 1. Validate PIN strength
        // 2. Hash with PBKDF2
        // 3. Store in keychain with separate key
        // 4. Initialize decoy vault
        
        let pinHash = hashPIN(panicPIN)
        
        configuration = PanicConfiguration(
            panicPINEnabled: true,
            panicPINHash: pinHash,
            decoyVaultPopulated: false,
            quickExitEnabled: true
        )
        
        savePanicConfiguration()
        
        return true
    }
    
    public func disablePanicMode() {
        configuration = .disabled
        currentVaultMode = .primary
        savePanicConfiguration()
        
        // Production: Securely wipe decoy vault
        SecureLogger.info("Panic mode disabled", category: "PanicMode")
    }
    
    // MARK: - PIN Authentication
    
    public enum AuthenticationResult {
        case primaryVault
        case decoyVault
        case failed
    }
    
    public func authenticate(pin: String) -> AuthenticationResult {
        // Check against primary PIN
        if validatePrimaryPIN(pin) {
            currentVaultMode = .primary
            return .primaryVault
        }
        
        // Check against panic PIN
        if configuration.panicPINEnabled, let panicHash = configuration.panicPINHash {
            if constantTimeCompare(hashPIN(pin), panicHash) {
                triggerPanicMode()
                return .decoyVault
            }
        }
        
        return .failed
    }
    
    // MARK: - Panic Mode Activation
    
    private func triggerPanicMode() {
        currentVaultMode = .decoy
        isActive = true
        
        SecureLogger.warning("Panic mode activated", category: "PanicMode")
        
        // Production implementation:
        // 1. Switch to decoy vault database
        // 2. Load decoy content
        // 3. Optional: Send silent alert
        // 4. Log activation timestamp
    }
    
    // MARK: - Decoy Vault Management
    
    public func populateDecoyVault(with assets: [DecoyAsset]) -> Bool {
        guard currentVaultMode == .primary else {
            SecureLogger.error("Cannot populate decoy vault while in panic mode", category: "PanicMode")
            return false
        }
        
        // Production implementation:
        // 1. Validate decoy assets
        // 2. Copy to decoy vault storage
        // 3. Encrypt with separate decoy key
        // 4. Update configuration
        
        var updatedConfig = configuration
        updatedConfig = PanicConfiguration(
            panicPINEnabled: updatedConfig.panicPINEnabled,
            panicPINHash: updatedConfig.panicPINHash,
            decoyVaultPopulated: true,
            quickExitEnabled: updatedConfig.quickExitEnabled
        )
        configuration = updatedConfig
        
        savePanicConfiguration()
        
        return true
    }
    
    public struct DecoyAsset {
        let id: UUID
        let imageData: Data
        let metadata: [String: Any]
    }
    
    // MARK: - Quick Exit
    
    public func triggerQuickExit() {
        guard configuration.quickExitEnabled else { return }
        
        // Production implementation:
        // 1. Clear sensitive data from memory
        // 2. Lock vault immediately
        // 3. Exit to home screen (via URL scheme hack)
        // 4. Optional: Clear recent screenshots
        
        SecureLogger.warning("Quick exit triggered", category: "PanicMode")
    }
    
    // MARK: - Security Utilities
    
    private func hashPIN(_ pin: String) -> Data {
        let salt = Data("nudefndr.panicpin.salt".utf8)
        let digest = SHA256.hash(data: Data(pin.utf8) + salt)
        return Data(digest)
    }
    
    private func validatePrimaryPIN(_ pin: String) -> Bool {
        // Production: Load primary PIN hash from keychain
        // Simplified for audit repo
        return true
    }
    
    private func constantTimeCompare(_ a: Data, _ b: Data) -> Bool {
        guard a.count == b.count else { return false }
        
        var result: UInt8 = 0
        for (x, y) in zip(a, b) {
            result |= x ^ y
        }
        
        return result == 0
    }
    
    // MARK: - Persistence
    
    private func loadPanicConfiguration() {
        // Production: Load from encrypted UserDefaults or keychain
        guard let data = UserDefaults.standard.data(forKey: "panicModeConfig") else {
            configuration = .disabled
            return
        }
        
        // Simplified decoding for audit
        configuration = .disabled
    }
    
    private func savePanicConfiguration() {
        // Production: Save to encrypted storage
        // Audit version: No-op
    }
    
    // MARK: - Status & Diagnostics
    
    public struct PanicModeStatus {
        let isConfigured: Bool
        let activeVault: VaultMode
        let decoyVaultReady: Bool
        let quickExitEnabled: Bool
        let lastActivation: Date?
    }
    
    public func getStatus() -> PanicModeStatus {
        return PanicModeStatus(
            isConfigured: configuration.panicPINEnabled,
            activeVault: currentVaultMode,
            decoyVaultReady: configuration.decoyVaultPopulated,
            quickExitEnabled: configuration.quickExitEnabled,
            lastActivation: nil
        )
    }
}

// MARK: - Forensic Resistance

extension PanicModeEngine {
    
    /// Clears sensitive data from memory
    public func zeroizeSensitiveMemory() {
        // Production implementation:
        // 1. Overwrite PIN hashes
        // 2. Clear authentication state
        // 3. Purge decrypted keys
        // 4. Reset vault mode
        
        isActive = false
    }
    
    /// Validates vault integrity
    public func validateVaultIntegrity() -> Bool {
        // Production implementation:
        // 1. Check for tampering
        // 2. Validate encryption keys
        // 3. Verify vault separation
        
        return true
    }
}