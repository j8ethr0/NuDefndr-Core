# NuDefndr Security Architecture

## Overview
This document outlines the security architecture of NuDefndr's core privacy components, demonstrating our commitment to user privacy and data protection.

## Core Security Principles

### 1. Zero-Trust Architecture
- All data encrypted at rest using End-to-end 256-bit encryption with ChaCha20-Poly1305
- Multiple layers of authentication and authorization
- Device-bound encryption keys with hardware backing

### 2. Privacy by Design
- No network transmission of sensitive data during analysis
- On-device ML processing using Apple's SensitiveContentAnalysis
- Anonymous telemetry collection with user consent

### 3. Defense in Depth
- Multi-layer encryption (AES-256 + ChaCha20-Poly1305)
- Hardware-backed key storage in Secure Enclave
- Biometric authentication requirements
- Panic mode with decoy vault architecture

## High-Level Architecture

					+---------------------------+
					|   iOS Application Layer   |
					|  (SwiftUI Views & State)  |
					+-------------+-------------+
								  |
					+-------------v-------------+
					|   Service Orchestration   |
					| ScanManager | VaultManager|
					|Authenticator| RouterState |
					+-------------+-------------+
								  |
			+---------------------+---------------------+
			|                     |                     |
	+-------v-------+     +-------v--------+    +------v-------+
	|   Analysis    |     |   Encryption   |    | Authentication|
	|    Engine     |     |     Layer      |    |    System     |
	+-------+-------+     +-------+--------+    +------+-------+
			|                     |                     |
	+-------v-------+     +-------v--------+    +------v-------+
	| Apple ML      |     | VaultCrypto    |    | Biometric +  |
	| Framework     |     | AES-256        |    | PIN Auth     |
	| (iOS 17+)     |     | ChaCha20-Poly  |    | Face/Touch ID|
	+---------------+     +-------+--------+    +------+-------+
								  |                     |
						  +-------v--------+    +------v-------+
						  |   Keychain     |    | Secure       |
						  |   Storage      |    | Enclave      |
						  +----------------+    +--------------+


## Data Flow: Photo Analysis Pipeline

	+----------------+
	| Photo Library  |
	| (iOS Photos)   |
	+-------+--------+
			|
			| 1. Request Access (Privacy)
			v
	+----------------+
	| PhotoLibrary   |
	| Service        |
	+-------+--------+
			|
			| 2. Fetch Assets (Incremental)
			v
	+----------------+
	|  ScanManager   |
	| - Batch Queue  |
	| - Throttling   |
	+-------+--------+
			|
			| 3. Analyze (On-Device)
			v
	+-------------------+
	| SensitiveContent  |
	| Service (Apple ML)|
	+--------+----------+
			 |
			 | 4. Results (Sensitive: Yes/No)
			 v
	+--------+----------+
	|   Results Store   |
	| (Ephemeral Cache) |
	+--------+----------+
			 |
			 | 5. User Action: Move to Vault
			 v
	+--------+----------+
	|   VaultManager    |
	+--------+----------+
			 |
			 | 6. Encrypt with AES-256
			 v
	+--------+----------+
	|   VaultCrypto     |
	+--------+----------+
			 |
			 | 7. Store Encrypted
			 v
	+--------+----------+
	| File System       |
	| (App Container)   |
	+-------------------+

NOTE: Zero network activity during this entire pipeline.


## Vault Encryption Flow

	+------------------+
	|  Sensitive Photo |
	+--------+---------+
			 |
			 | User Action: "Move/Copy to Vault"
			 v
	+--------+---------+
	| Authentication   |
	| Required         |
	| - Face/Touch ID  |
	| - PIN Fallback   |
	+--------+---------+
			 |
			 | Success
			 v
	+--------+---------+
	| Retrieve Key     |
	| from Keychain    |
	| (Secure Enclave) |
	+--------+---------+
			 |
			 | Device-Bound Key
			 v
	+--------+---------+
	| VaultCrypto      |
	| Encrypt:         |
	| AES-256-GCM or   |
	| ChaCha20-Poly1305|
	+--------+---------+
			 |
			 | Encrypted Blob + Nonce + Tag
			 v
	+--------+---------+
	| Write to Disk    |
	| App Container    |
	| (Encrypted)      |
	+------------------+


## Panic Mode Architecture

	+------------------+         +------------------+
	|  Primary Vault   |         |   Decoy Vault    |
	|                  |         |                  |
	| - Real sensitive |         | - Empty Vault    |
	|   content        |         |                  |
	| - Primary PIN    |         | - Panic PIN      |
	| - Full features  |         | - Limited access |
	+--------+---------+         +--------+---------+
			 |                            |
			 |                            |
	+--------v----------------------------v---------+
	|          Authentication Layer                |
	|                                               |
	|  Primary PIN   -->  Primary Vault            |
	|  Panic PIN     -->  Decoy Vault              |
	|                                               |
	|  Indistinguishable UI/UX between modes       |
	+-----------------------------------------------+


## Key Management Lifecycle

	1. App Install
	   |
	   v
	Generate Symmetric Key (256-bit)
	   |
	   v
	Derive Device-Bound Key (UDID + Salt)
	   |
	   v
	Store in Keychain with Attributes:
	- kSecAttrAccessibleWhenUnlockedThisDeviceOnly
	- Biometric protection required
	   |
	   v
	Key Available for Encryption/Decryption
	   |
	   v
	(Optional) Key Rotation Every 90 Days
	   |
	   v
	Re-encrypt Vault with New Key
	   |
	   v
	Old Key Zeroized from Memory


## Security Boundaries

	+---------------------------------------+
	|          iOS Sandbox                  |
	|  +----------------------------------+ |
	|  |      NuDefndr Process            | |
	|  |                                  | |
	|  |  +----------------------------+  | |
	|  |  | Analysis Engine            |  | |
	|  |  | (No Network Access)        |  | |
	|  |  +----------------------------+  | |
	|  |                                  | |
	|  |  +----------------------------+  | |
	|  |  | Vault Storage              |  | |
	|  |  | (Encrypted at Rest)        |  | |
	|  |  +----------------------------+  | |
	|  |                                  | |
	|  +----------------------------------+ |
	|                                       |
	|  +----------------------------------+ |
	|  | iOS Keychain (System Service)    | |
	|  | - Device-Bound Keys              | |
	|  | - Biometric Protection           | |
	|  +----------------------------------+ |
	|                                       |
	|  +----------------------------------+ |
	|  | Secure Enclave (Hardware)        | |
	|  | - Key Generation                 | |
	|  | - Crypto Operations              | |
	|  +----------------------------------+ |
	+---------------------------------------+
			 |                    |
			 v                    v
	Network (BLOCKED)      Backup (Keys Excluded)


## Threat Mitigation Summary

| Threat                    | Mitigation                              |
|---------------------------|-----------------------------------------|
| Network Interception      | Zero network activity (verifiable)      |
| Device Theft (Locked)     | Biometric + PIN required                |
| Device Theft (Unlocked)   | Auto-lock after 30s                     |
| Backup Extraction         | Keys not backed up (device-only)        |
| Coercion                  | Panic Mode (decoy vault)                |
| Memory Forensics          | Key clearing on background              |
| Jailbreak                 | Detection (10 vectors)                  |
| Code Tampering            | Signature validation                    |


## Component Security Details

### SensitiveContentService
- **Threat Model**: Prevent data exfiltration during analysis
- **Mitigation**: Sandboxed analysis, memory protection, timeout controls
- **Privacy Guarantee**: Zero network communication during processing

### VaultCrypto
- **Threat Model**: Protect encrypted data from unauthorized access
- **Mitigation**: Industry-standard encryption, key rotation, secure memory management
- **Standards Compliance**: FIPS 140-2 Level 1 where supported

### KeychainSecure
- **Threat Model**: Secure key storage and retrieval
- **Mitigation**: Hardware-backed storage, biometric protection, access control
- **Security Features**: Secure Enclave integration, anti-tampering

### PanicModeCore
- **Threat Model**: Coercion and forced access scenarios
- **Mitigation**: Dual-vault architecture, decoy data, emergency protocols
- **Advanced Features**: Duress detection, emergency wipe capabilities

## Version 2.1.3 Security Improvements

### Vault Privacy Controls
- **Configurable Metrics Display**: Pro users can optionally enable item count display on lock screen
- **Privacy-Preserving Queries**: Vault metadata accessible without decryption or unlock

### Enhanced Lock Screen Architecture
- **Real-Time Security Status**: Clear presentation of encryption status and storage mode

## Version 2.1.2 Security Improvements

### Scan Architecture Hardening
- **Race Condition Fix**: Eliminated completion detection race in automatic scans
- **Timestamp Unification**: Single source of truth for scan history prevents inconsistent state
- **Crash Mitigation**: Resolved fatal error when background tasks fire without previous scan data
- **Adaptive Logic**: Background scans detect iOS throttling and automatically widen scan range

### Background Task Security
- **Completion Guarantee**: Reliable completion state detection
- **State Isolation**: Automatic scan jobs never interfere with manual scan state
- **Scheduling Discipline**: Single-pending-request prevents iOS throttling from excessive submissions

### Vault Enhancements
- **Smart Filtering**: Date-based organization with persistent preferences
- **Enhanced Sorting**: Newest/oldest first with automatic date grouping
- **Batch Operations**: Select all visible items with efficient filtering
- **Memory Optimization**: Computed properties ensure efficient vault operations

## Audit and Compliance

This codebase has been designed with security auditing in mind:
- Clear separation of concerns
- Comprehensive error handling
- Detailed logging for security events
- Compliance with industry best practices

## Security Assumptions

1. iOS/macOS security model integrity
2. Hardware security features (Secure Enclave) availability
3. Apple's SensitiveContentAnalysis framework privacy guarantees
4. User adherence to strong authentication practices

---
**Last Updated**: December 18, 2025  
**Version**: 2.1.3  
**Contact**: security@nudefndr.com
