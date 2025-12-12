// Copyright (c) 2025 Dro1d Labs Limited
// Released under the MIT License. See LICENSE file for details.
//
// NuDefndr App - Panic Mode Configuration
// App Website: https://nudefndr.com
// Developer: Dro1d Labs

import Foundation

/// Configuration and constants for Panic Mode system
public struct PanicModeConfig {
    
    // MARK: - Security Constants
    
    /// Minimum panic PIN length
    public static let minPINLength = 4
    
    /// Maximum panic PIN length
    public static let maxPINLength = 8
    
    /// PBKDF2 rounds for panic PIN hashing
    public static let pinHashRounds: UInt32 = 150_000
    
    /// Maximum failed authentication attempts before lockout
    public static let maxFailedAttempts = 5
    
    /// Lockout duration after max failed attempts (seconds)
    public static let lockoutDuration: TimeInterval = 300 // 5 minutes
    
    // MARK: - Vault Configuration
    
    /// Decoy vault storage key
    public static let decoyVaultStorageKey = "com.nudefndr.decoy.vault"
    
    /// Primary vault storage key
    public static let primaryVaultStorageKey = "com.nudefndr.primary.vault"
    
    /// Maximum decoy vault size (items)
    public static let maxDecoyVaultSize = 50
    
    /// Recommended minimum decoy vault items
    public static let recommendedMinDecoyItems = 10
    
    // MARK: - Behavioral Constants
    
    /// Delay before switching vaults (milliseconds)
    public static let vaultSwitchDelay: UInt64 = 250_000_000 // 250ms
    
    /// Quick exit URL scheme
    public static let quickExitURLScheme = "prefs:root=General"
    
    /// Memory wipe iterations
    public static let memoryWipeIterations = 3
    
    // MARK: - Feature Flags
    
    /// Enable silent alert on panic activation
    public static let enableSilentAlert = false
    
    /// Log panic mode activations
    public static let logActivations = true
    
    /// Show panic mode in settings
    public static let showInSettings = true
    
    // MARK: - Validation
    
    /// Validates panic PIN meets security requirements
    public static func validatePIN(_ pin: String) -> PINValidationResult {
        guard pin.count >= minPINLength else {
            return .tooShort
        }
        
        guard pin.count <= maxPINLength else {
            return .tooLong
        }
        
        // Check if PIN is all same digits
        let uniqueChars = Set(pin)
        if uniqueChars.count == 1 {
            return .tooWeak
        }
        
        // Check for sequential patterns (1234, 4321, etc.)
        if isSequential(pin) {
            return .tooWeak
        }
        
        return .valid
    }
    
    public enum PINValidationResult {
        case valid
        case tooShort
        case tooLong
        case tooWeak
        case matchesPrimaryPIN
        
        public var errorMessage: String {
            switch self {
            case .valid:
                return ""
            case .tooShort:
                return "PIN must be at least \(PanicModeConfig.minPINLength) digits"
            case .tooLong:
                return "PIN must be at most \(PanicModeConfig.maxPINLength) digits"
            case .tooWeak:
                return "PIN is too weak (avoid repeating or sequential digits)"
            case .matchesPrimaryPIN:
                return "Panic PIN cannot match your primary PIN"
            }
        }
    }
    
    private static func isSequential(_ pin: String) -> Bool {
        guard pin.count > 2 else { return false }
        
        let digits = pin.compactMap { Int(String($0)) }
        guard digits.count == pin.count else { return false }
        
        // Check ascending
        var isAscending = true
        for i in 1..<digits.count {
            if digits[i] != digits[i-1] + 1 {
                isAscending = false
                break
            }
        }
        
        if isAscending { return true }
        
        // Check descending
        var isDescending = true
        for i in 1..<digits.count {
            if digits[i] != digits[i-1] - 1 {
                isDescending = false
                break
            }
        }
        
        return isDescending
    }
    
    // MARK: - Threat Scenarios
    
    public enum ThreatLevel: String {
        case low = "Low Risk"
        case medium = "Medium Risk"
        case high = "High Risk"
        case critical = "Critical Risk"
    }
    
    public struct ThreatScenario {
        let level: ThreatLevel
        let description: String
        let recommendedAction: String
    }
    
    public static let threatScenarios: [ThreatScenario] = [
        ThreatScenario(
            level: .low,
            description: "Casual inspection by acquaintance",
            recommendedAction: "Panic mode with basic decoy vault"
        ),
        ThreatScenario(
            level: .medium,
            description: "Coercion by partner/family member",
            recommendedAction: "Panic mode with populated decoy vault"
        ),
        ThreatScenario(
            level: .high,
            description: "Aggressive coercion with threats",
            recommendedAction: "Panic mode + Quick Exit enabled"
        ),
        ThreatScenario(
            level: .critical,
            description: "Legal/forensic investigation",
            recommendedAction: "Panic mode NOT effective (consult legal counsel)"
        )
    ]
}

// MARK: - Decoy Content Suggestions

extension PanicModeConfig {
    
    public enum DecoyContentType: String, CaseIterable {
        case landscapes = "Landscape Photos"
        case food = "Food & Dining"
        case pets = "Pet Photos"
        case documents = "Documents/Screenshots"
        case memes = "Memes & Funny Images"
        
        public var description: String {
            switch self {
            case .landscapes:
                return "Generic landscape/nature photos for plausibility"
            case .food:
                return "Food photos from restaurants or home cooking"
            case .pets:
                return "Pet photos (if you have pets)"
            case .documents:
                return "Screenshots of receipts, tickets, or documents"
            case .memes:
                return "Memes or funny images saved from social media"
            }
        }
    }
    
    public static let recommendedDecoyTypes: [DecoyContentType] = [
        .landscapes,
        .food,
        .pets,
        .memes
    ]
}