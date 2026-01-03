![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg) ![iOS](https://img.shields.io/badge/iOS-18+-lightgrey.svg) ![Security](https://img.shields.io/badge/Security-Hardened-black.svg) ![License](https://img.shields.io/badge/License-MIT-blue.svg)

# NuDefndr — Core Privacy Components

**NuDefndr** is a privacy-first iOS app for detecting and securing sensitive content in your photo library—entirely on-device. This repository contains auditable security components used by the app (proprietary UI and business logic are closed-source).

Quick links: [nudefndr.com](https://nudefndr.com) · [App Store](https://apps.apple.com/de/app/nudefndr/id6745149292) · Dro1d Labs Limited

---

## Table of contents

- What is NuDefndr?
- Privacy Guarantees
- Repository Components
- Security Architecture
- Running Tests & Build
- Contributing
- Contact

---

## What is NuDefndr?

NuDefndr scans your iPhone photo library for sensitive, explicit, or NSFW content using Apple’s on-device machine learning—no cloud processing, no data transmission, no tracking.

Core features
- **On-Device Detection** — Uses Apple's SensitiveContentAnalysis framework (iOS 17+)
- **Encrypted Vault** — AES-256 + ChaCha20-Poly1305 encryption (hardware-backed). See `/Vault/VaultCrypto.swift` for implementation.
- **Panic Mode** — Dual-vault system with emergency concealment
- **Background Scanning** — Automatic protection with incremental updates
- **Zero Network Activity** — 100% local processing (verifiable)

Who it's for: parents, individuals protecting sensitive photos, privacy-conscious users, and security researchers.

---

## 🔒 Privacy Guarantees

NuDefndr enforces strict, verifiable privacy controls:

| Guarantee | Implementation | Verification |
|-----------|----------------|--------------|
| Zero network transmission | No URLSession calls in analysis pipeline | Inspect `Security/SensitiveContentService.swift` |
| 100% on-device processing | Apple SensitiveContentAnalysis only | iOS 17+ framework requirement |
| Hardware-backed encryption | Keys stored in Secure Enclave | `Vault/VaultCrypto.swift` + `Vault/KeychainSecure.swift` |
| No analytics/tracking | No telemetry in detection flow | Audit `/Security` directory |

How to verify: review the files listed in the Repository Components section, run the tests, and inspect network logs during a scan.

---

## 🧱 Repository Components

This repository exposes the auditable privacy and security architecture. It is not a complete app.

### Core analysis engine
- `SensitiveContentService.swift` — Apple SensitiveContentAnalysis wrapper with batch processing
- `ScanRangeOption.swift` — Immutable scan range definitions (7 days, 30 days, etc.)

### Security & encryption
- `Vault/VaultCrypto.swift` — AES-256 + ChaCha20-Poly1305 encryption
- `Vault/KeychainSecure.swift` — Secure Enclave key derivation and lifecycle management
- `Security/JailbreakDetection.swift` — 10-vector jailbreak detection
- `Security/AntiTampering.swift` — Code signature validation and integrity checks

### Panic mode
- `PanicMode/PanicModeEngine.swift` — Dual-vault architecture for emergency concealment
- `PanicMode/PanicModeConfig.swift` — Configuration and decoy vault management

### Tests & docs
- `Tests/CryptoTests.swift` — Cryptographic unit tests
- `Tests/SecurityTests.swift` — Jailbreak detection and anti-tampering validation
- `Docs/SECURITY.md`, `Docs/PERFORMANCE.md`, `Docs/THREAT_MODEL.md`, `Docs/SecurityArchitecture.md`

---

## 🧱 Security Architecture (summary)

User Photo → Authentication Required → Retrieve Key from Keychain → Secure Enclave Key → VaultCrypto (AES-256-GCM or ChaCha20-Poly1305) → Encrypted Blob + Nonce + Auth Tag → Write to App Container (Encrypted)

Key lifecycle highlights
1. App install → generate 256-bit symmetric key
2. Device-bound key derivation
3. Keychain storage with `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` + biometric protection
4. Key zeroization on deallocation

---

## 🧪 Running tests & build

Run tests:
```
swift test --filter CryptoTests
swift test --filter SecurityTests
swift test --filter PerformanceBenchmarkSuite
```

Quick build (Swift Package Manager):
```
swift build
swift test
```

Tests include AES-256 and ChaCha20-Poly1305 round-trips, PBKDF2 consistency, entropy checks, timing-attack resistance, jailbreak detection, and anti-tampering checks.

---

## 🚀 Performance highlights

Version 2.0+ incremental scanning provides significant speed and battery improvements (see `Docs/PERFORMANCE.md` for full benchmarks).

---

## 🤝 Contributing

We welcome security research and documentation improvements. Do not open public issues for security vulnerabilities — report privately to security@nudefndr.com with a description, PoC (if safe), steps to reproduce, and impact assessment.

See `CONTRIBUTING.md` for guidelines.

---

## 📞 Contact

- Website: https://nudefndr.com
- App Store: https://apps.apple.com/de/app/nudefndr/id6745149292
- Support: support@nudefndr.com
- Security: security@nudefndr.com

---

**Version:** 2.1.7
**Last Updated:** January 2026
**Maintained by:** Dro1d Labs Limited
