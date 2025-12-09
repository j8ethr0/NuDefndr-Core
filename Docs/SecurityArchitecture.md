# NuDefndr Security Architecture

## Overview
This document outlines the security architecture of NuDefndr's core privacy components, demonstrating our commitment to user privacy and data protection.

# Nude Finder # Nude Defender # Nu Defndr # iOS


## Core Security Principles

### 1. Zero-Trust Architecture
- All data encrypted at rest using military-grade encryption
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

## Component Security Details

### SensitiveContentService
- **Threat Model**: Prevent data exfiltration during analysis
- **Mitigation**: Sandboxed analysis, memory protection, timeout controls
- **Privacy Guarantee**: Zero network communication during processing

### VaultCrypto
- **Threat Model**: Protect encrypted data from unauthorized access
- **Mitigation**: Military-grade encryption, key rotation, secure memory management
- **Standards Compliance**: FIPS 140-2 Level 1 where supported

### KeychainSecure
- **Threat Model**: Secure key storage and retrieval
- **Mitigation**: Hardware-backed storage, biometric protection, access control
- **Security Features**: Secure Enclave integration, anti-tampering

### PanicModeCore
- **Threat Model**: Coercion and forced access scenarios
- **Mitigation**: Dual-vault architecture, decoy data, emergency protocols
- **Advanced Features**: Duress detection, emergency wipe capabilities

## Security Architecture

**Vault Encryption**: AES-256 with device-specific keys stored in Secure Enclave  
**Panic Mode**: Separate decoy vault accessible via emergency PIN  
**Key Management**: Hardware-backed keychain with biometric protection  
**Version 2.0 Enhancements**: Incremental scanning architecture with unified timestamp system

## Version 2.0 Security Improvements

### Scan Architecture Hardening
- **Race Condition Fix**: Eliminated completion detection race in automatic scans
- **Timestamp Unification**: Single source of truth for scan history prevents inconsistent state
- **Crash Mitigation**: Resolved fatal error when background tasks fire without previous scan data
- **Adaptive Logic**: Background scans detect iOS throttling and automatically widen scan range

### Background Task Security
- **Completion Guarantee**: 100ms delay ensures reliable completion state detection
- **State Isolation**: Automatic scan jobs never interfere with manual scan state
- **Scheduling Discipline**: Single-pending-request prevents iOS throttling from excessive submissions

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
**Last Updated**: December 2025  
**Version**: 2.0.0
**Contact**: security@nudefndr.com