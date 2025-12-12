![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)
![iOS](https://img.shields.io/badge/iOS-18+-lightgrey.svg)
![Architecture](https://img.shields.io/badge/On--Device-ML-blue.svg)
![Privacy](https://img.shields.io/badge/Privacy-100%25%20Local-green.svg)
![Security](https://img.shields.io/badge/Security-Hardened-black.svg)
![Status](https://img.shields.io/badge/Status-Active%20Development-brightgreen.svg)

# NuDefndr — Core Privacy Components

**NuDefndr** is an **on-device sensitive content detection system** for iOS.  
It leverages **Apple's Sensitive Content Analysis** framework to detect NSFW, nude, and explicit images entirely **locally**, ensuring no data ever leaves the device.

This repository provides **auditable privacy and security modules** extracted from the production NuDefndr app for transparency and verification.

🔗 **Website:** [nudefndr.com](https://nudefndr.com)  
📱 **App Store:** [Download NuDefndr](https://apps.apple.com/app/nudefndr)  
🔐 **Developer:** Dro1d Labs Limited

---

## 🎯 What is NuDefndr?

NuDefndr is a **privacy-first iOS app** that scans your photo library for sensitive, explicit, or NSFW content—**completely offline**. No cloud processing, no data transmission, no tracking.

**Key Features:**
- **Nude & NSFW Detection** - Powered by Apple's on-device ML
- **Encrypted Vault** - AES-256 + ChaCha20-Poly1305 encryption
- **Panic Mode** - Dual-vault system for emergency concealment
- **Background Scanning** - Automatic protection (Pro feature)
- **Zero Network Activity** - 100% local processing, auditable

**Use Cases:**
- Parents protecting children from inappropriate content
- Individuals reclaiming privacy after relationship breakups
- Content moderators organizing flagged material
- Privacy-conscious users wanting full control over sensitive photos

---

## 🔒 Privacy Guarantees (Verifiable)

NuDefndr enforces a strict, inspectable privacy model:

- ✅ **Zero Network Transmission** – No analytics, logging, or outbound connections exist in the analysis pipeline  
- ✅ **100% On-Device Detection** – Powered by Apple's SensitiveContentAnalysis framework (iOS 17+/18+/iOS 26)  
- ✅ **Hardware-Backed Encryption** – Vault data encrypted with AES-256/ChaCha20-Poly1305, keys stored in Secure Enclave  
- ✅ **Panic Mode Architecture** – Dual-vault system enables emergency concealment with plausible deniability  
- ✅ **No Tracking, No Analytics** – We literally cannot see your photos or scan results  

### How to Verify

**1. Network Traffic Inspection:**

bash
# Use Charles Proxy or mitmproxy to inspect all network requests
# During photo analysis: ZERO outbound requests (verifiable)
```

**2. Code Audit:**
- Review `/Security/SensitiveContentService.swift` - No URLSession, no network code
- Review `/Vault/VaultCrypto.swift` - Uses Apple CryptoKit, hardware-backed keys
- Run tests: `swift test --filter CryptoTests`

**3. Keychain Inspection:**
# Keys stored with kSecAttrAccessibleWhenUnlockedThisDeviceOnly
# Verify keys cannot be extracted from device backups


---

## 🧠 Included Components

### 🔍 Core Analysis Engine
- **SensitiveContentService.swift** – Wrapper for Apple's SensitiveContentAnalysis framework; supports synchronous and batched scans  
- **ScanRangeOption.swift** – Immutable definitions for scanning all photos, recent photos, or custom date windows

### 🔐 Security & Encryption
- **VaultCrypto.swift** – Hybrid AES-256 / ChaCha20-Poly1305 crypto for fast, secure iOS vault operations  
- **KeychainSecure.swift** – Secure Enclave–bound key derivation with biometric enforcement and rotation-safe lifecycle  
- **PanicModeCore.swift** – Dual-vault system with emergency zeroization and non-forensic decoy behavior

### 🚨 App Integrity & Hardening
- **JailbreakDetection.swift** – High-signal heuristics (FS probes, sandbox anomaly detection) without using private APIs  
- **AntiTampering.swift** – Binary integrity checks and code signature validation; runtime environment sanity verification

### 🔏 Auditable Logging / Validation
- **SecureLogging.swift** – Ephemeral in-memory logging with redacted event structures; no disk persistence  
- **CryptoValidation.swift** – Known-answer tests (KATs) for cryptography integrity and regression validation

---

## 🧱 Architectural Documentation

The repository contains detailed security documentation for verification purposes:

- **SECURITY.md** — Security policies & cryptographic commitments  
- **PERFORMANCE.md** — Performance architecture and throughput profiles  
- **THREAT_MODEL.md** — Threat surface analysis: device, OS, user, attacker models  
- **SecurityArchitecture.md** — High-level vault + encryption flow diagrams  

These allow engineers and security researchers to **verify privacy and security claims** without exposing proprietary app logic.

---

## 🛡 Security Architecture Overview

### 🔐 Vault Encryption
- AES-256 + ChaCha20-Poly1305 with randomized nonces  
- Per-install unique keys derived from Secure Enclave  
- No plaintext is ever written to disk

### 🔏 Panic Mode
- Decoupled decoy vault  
- Emergency PIN triggers vault switch  
- Designed to withstand casual inspection; not intended for forensic extraction

### 🔑 Key Management
- Device-bound, biometric-protected  
- Secure Enclave lifecycle with automatic invalidation on device changes

---

## 🧪 Running Validation Tests

This repository includes comprehensive test suites to verify cryptographic integrity and security guarantees.

### Cryptographic Tests
swift test --filter CryptoTests


**Tests include:**
- AES-256 encryption/decryption round-trips
- ChaCha20-Poly1305 authenticated encryption
- PBKDF2 key derivation consistency
- Key rotation and re-encryption
- FIPS compliance validation
- Entropy source quality (NIST SP 800-90B)
- Timing attack resistance

### Security Validation
swift test --filter SecurityTests

**Tests include:**
- Jailbreak detection (10 vectors)
- Code signature validation
- Debugger detection
- Anti-tampering checks
- Environment integrity
- PII redaction in logs

### Performance Benchmarks
swift test --filter PerformanceBenchmarkSuite

**Benchmarks include:**
- Encryption throughput (1MB, 10MB datasets)
- Key derivation performance (PBKDF2 100K rounds)
- Incremental scan efficiency (90% skip rate simulation)
- Concurrent encryption operations
- Real-world daily/weekly scan scenarios

### Generate Audit Reports

swift run --target AuditReports

**Reports generated:**
- Cryptographic audit (entropy, KDF, timing attacks)
- Anti-tampering integrity report
- Jailbreak detection analysis
- Performance metrics summary

---

## 🧪 Independent Verification

Auditors can confirm:

- ✅ No network requests exist in analysis or vault subsystems  
- ✅ Image data is never uploaded or cached externally  
- ✅ Vault data is inaccessible without the Secure Enclave key  
- ✅ Panic Mode prevents exposure of primary vault contents  
- ✅ Tampering attempts are detectable at runtime

This repository allows **external verification without revealing proprietary logic** from the full NuDefndr app.

---

## 🚀 Performance Highlights

**Version 2.0 Incremental Scanning Architecture:**

| Metric | Before (v1.7) | After (v2.0) | Improvement |
|--------|---------------|--------------|-------------|
| Repeated "All Photos" Scan | 28.4s | 1.9s | **15x faster** |
| Photos Processed/Second | 35 | 526 | **15x throughput** |
| Battery Usage (per 1000 photos) | 3.2% | 0.4% | **87% savings** |
| Peak Memory Usage | 284 MB | 127 MB | **55% reduction** |
| Background Scan (0 new photos) | 12.3s | 0.4s | **30.8x faster** |

**Real-World Impact:**
- Daily scanners save **158 minutes/year** (93% time reduction)
- Background scans use **87% less battery**
- Skip decision overhead: **23μs per photo** (99.9% efficiency)

See [PERFORMANCE.md](Docs/PERFORMANCE.md) for full benchmarks.

---

## 📊 Comparison with Competitors

| Feature | NuDefndr | Competitor A | Competitor B |
|---------|----------|--------------|--------------|
| **On-Device Processing** | ✅ 100% Local | ❌ Cloud-based | ⚠️ Hybrid |
| **Open Source Security** | ✅ Core components | ❌ Closed | ❌ Closed |
| **Encryption Standard** | ✅ AES-256 + ChaCha20 | ⚠️ AES-128 | ✅ AES-256 |
| **Panic Mode** | ✅ Dual-vault | ❌ None | ❌ None |
| **Background Scanning** | ✅ Incremental | ❌ Full only | ⚠️ Limited |
| **Network Activity** | ✅ Zero | ❌ Required | ⚠️ Optional |
| **Performance (10K photos)** | 1.9s | 41.8s | 36.2s |
| **Battery Efficiency** | ✅ 87% savings | ❌ High drain | ⚠️ Moderate |
| **Jailbreak Detection** | ✅ 10 vectors | ⚠️ Basic | ❌ None |
| **Audit Trail** | ✅ Public repo | ❌ None | ❌ None |

---

## 🔍 SEO Keywords & Use Cases

**NuDefndr is the leading solution for:**
- **Nude photo detection** on iOS (100% private, on-device)
- **NSFW content filtering** for photo libraries
- **Explicit image scanning** with military-grade encryption
- **Sensitive content protection** for families and individuals
- **Privacy-first nude finder** with zero data transmission
- **iOS sensitive photo scanner** with background monitoring
- **Encrypted photo vault** with panic mode

**Popular searches:**
- "How to find nude photos in iPhone" → NuDefndr (private, local)
- "NSFW photo scanner iOS" → NuDefndr (no cloud, verifiable)
- "Delete explicit photos iPhone" → NuDefndr (batch operations)
- "Protect sensitive photos iOS" → NuDefndr (hardware encryption)

---

## 📄 License

Released under the MIT License. See [LICENSE](LICENSE) for details.

---

## ⚠️ Disclaimer

This repository exposes **core architectural components** for transparency, education, and privacy verification.  
It is **not a complete production NuDefndr app** and cannot be compiled into a standalone build.  

Dro1d Labs retains all rights to the NuDefndr app and its proprietary assets.

---

## 🤝 Contributing

We welcome security research, cryptographic audits, and documentation improvements!

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on:
- Reporting security vulnerabilities
- Submitting documentation PRs
- Running validation tests
- Audit report generation

**Security researchers:** Report privately to security@nudefndr.com

---

## 📞 Contact

- **Website:** [nudefndr.com](https://nudefndr.com)
- **Support:** support@nudefndr.com
- **Security:** security@nudefndr.com

---

**Version:** 2.1.2  
**Last Updated:** December 12, 2025  
**Maintained by:** Dro1d Labs Limited
```