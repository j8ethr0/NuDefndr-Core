[Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)
![iOS](https://img.shields.io/badge/iOS-18+-lightgrey.svg)
![Architecture](https://img.shields.io/badge/On--Device-ML-blue.svg)
![Privacy](https://img.shields.io/badge/Privacy-100%25%20Local-green.svg)
![Security](https://img.shields.io/badge/Security-Hardened-black.svg)
![Status](https://img.shields.io/badge/Status-Active%20Development-brightgreen.svg)

# NuDefndr — Core Privacy Components

NuDefndr is an **on-device sensitive content detection system** for iOS.  
It leverages **Apple’s Secure Sensitive Content Analysis** frameworks to detect NSFW, nude, and explicit images entirely **locally**, ensuring no data ever leaves the device.

This repository provides **auditable privacy and security modules** extracted from the production NuDefndr app.

🔗 **Website:** [nudefndr.com](https://nudefndr.com)  
🔐 **Developer:** Dro1d Labs

---

## 🔒 Privacy Guarantees (Verifiable)

NuDefndr enforces a strict, inspectable privacy model:

- **Zero Network Transmission** – No analytics, logging, or outbound connections exist in the analysis pipeline.  
- **100% On-Device Detection** – Powered by Apple’s SensitiveContentAnalysis framework (iOS 17+/18+/iOS26).  
- **Hardware-Backed Encryption** – Vault data is encrypted using AES-256 / ChaCha20-Poly1305 with Secure Enclave–derived keys.  
- **Panic Mode Architecture** – Dual-vault system enables emergency concealment and rapid obfuscation.

---

## 🧠 Included Components

### 🔍 Core Analysis Engine
- SensitiveContentService.swift – Wrapper for Apple’s SensitiveContentAnalysis framework; supports synchronous and batched scans.  
- ScanRangeOption.swift – Immutable definitions for scanning all photos, recent photos, or custom date windows.

### 🔐 Security & Encryption
- VaultCrypto.swift – Hybrid AES-256 / ChaCha20-Poly1305 crypto for fast, secure iOS vault operations.  
- KeychainSecure.swift – Secure Enclave–bound key derivation with biometric enforcement and rotation-safe lifecycle.  
- PanicModeCore.swift – Dual-vault system with emergency zeroization and non-forensic decoy behavior.

### 🚨 App Integrity & Hardening
- JailbreakDetection.swift – High-signal heuristics (FS probes, sandbox anomaly detection) without using private APIs.  
- AntiTampering.swift – Binary integrity checks and code signature validation; runtime environment sanity verification.

### 🔏 Auditable Logging / Validation
- SecureLogging.swift – Ephemeral in-memory logging with redacted event structures; no disk persistence.  
- CryptoValidation.swift – Known-answer tests (KATs) for cryptography integrity and regression validation.

---

## 🧱 Architectural Documentation

The repository contains detailed security documentation for verification purposes:

- SECURITY.md — Security policies & cryptographic commitments.  
- PERFORMANCE.md — Performance architecture and throughput profiles.  
- THREAT_MODEL.md — Threat surface analysis: device, OS, user, attacker models.  
- SecurityArchitecture.md — High-level vault + encryption flow diagrams.  

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

## 🧪 Independent Verification

Auditors can confirm:

- No network requests exist in analysis or vault subsystems  
- Image data is never uploaded or cached externally  
- Vault data is inaccessible without the Secure Enclave key  
- Panic Mode prevents exposure of primary vault contents  
- Tampering attempts are detectable at runtime

This repository allows **external verification without revealing proprietary logic** from the full NuDefndr app.

---

## 📄 License

Released under the MIT License. See LICENSE for details.

---

## ⚠️ Disclaimer

This repository exposes **core architectural components** for transparency, education, and privacy verification.  
It is **not a complete production NuDefndr app** and cannot be compiled into a standalone build.  

Dro1d Labs retains all rights to the NuDefndr app and its proprietary assets.
