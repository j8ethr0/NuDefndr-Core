# NuDefndr - Core Privacy Components

This repository contains auditable open-source components from the NuDefndr iOS app, focusing on core privacy and security functions.

**App Website**: https://nudefndr.com

## Privacy Guarantees (Verifiable)

- **Zero Network Transmission** - No network code in analysis pipeline
- **On-Device Analysis Only** - Apple's SensitiveContentAnalysis framework  
- **Military-Grade Encryption** - AES-256 ChaCha20-Poly1305 implementation
- **Panic Mode Protection** - Dual-vault architecture for emergency situations

## Included Components

### Core Analysis
- `SensitiveContentService.swift` - Apple framework integration
- `ScanRangeOption.swift` - Date range definitions

### Security & Encryption  
- `VaultCrypto.swift` - Encryption/decryption implementation
- `KeychainSecure.swift` - Secure key storage utilities
- `PanicModeCore.swift` - Dual-vault architecture

## Security Architecture

**Vault Encryption**: AES-256 with device-specific keys stored in Secure Enclave  
**Panic Mode**: Separate decoy vault accessible via emergency PIN  
**Key Management**: Hardware-backed keychain with biometric protection  

## Independent Verification

Security researchers can verify:
- Image data never leaves the device during analysis
- Encrypted vault data is unreadable without device + biometric access  
- Panic PIN creates truly separate, isolated storage containers

## License

Released under the MIT License. See LICENSE file for details.

## Disclaimer

This code is provided for transparency purposes. It represents select core components but is not the complete, buildable application.

Developer: Dro1d Labs