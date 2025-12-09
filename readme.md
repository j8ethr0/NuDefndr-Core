![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)
![iOS](https://img.shields.io/badge/iOS-18+-lightgrey.svg)
![Architecture](https://img.shields.io/badge/On--Device-ML-blue.svg)
![Privacy](https://img.shields.io/badge/Privacy-100%25%20Local-green.svg)
![Security](https://img.shields.io/badge/Security-Hardened-black.svg)
![Status](https://img.shields.io/badge/Status-Active%20Development-brightgreen.svg)

# NuDefndr — Core Privacy Components

NuDefndr is an **on-device sensitive content detection system** for iOS.  
It uses **Apple’s Secure Sensitive Content Analysis** frameworks to detect NSFW, nude, and explicit images entirely **locally**—never leaving the device.

This repository contains **auditable** privacy-and-security modules extracted from the production NuDefndr app.

🔗 **Website:** https://nudefndr.com  
🔐 **Developer:** Dro1d Labs

---

## 🔒 Privacy Guarantees (Verifiable)

NuDefndr is designed with a strict, inspectable privacy model:

- **Zero Network Transmission**  
  No analytics, no logging, *no* outbound connections. No network code exists in the analysis pipeline.

- **100% On-Device Detection**  
  Powered by Apple’s SensitiveContentAnalysis framework (iOS 17+ / 18+ / iOS26).

- **Hardware-Backed Encryption**  
  Vault data uses AES-256 / ChaCha20-Poly1305 with Secure Enclave–derived keys.

- **Panic Mode Architecture**  
  Dual-vault system providing emergency concealment and rapid obfuscation.

---

## 🧠 Included Components

### 🔍 Core Analysis Engine
- `SensitiveContentService.swift`  
  – Wrapper for Apple’s SensitiveContentAnalysis framework  
  – Runs synchronous and batched scans  
  – Respects sandbox + memory constraints

- `ScanRangeOption.swift`  
  – Immutable definitions for scanning “All Photos”, “Recent Photos”, or specific date windows

### 🔐 Security & Encryption
- `VaultCrypto.swift`  
  – AES-256 / ChaCha20-Poly1305 hybrid crypto  
  – Built for low-latency iOS file vault operations

- `KeychainSecure.swift`  
  – Hardware-bound key derivation  
  – Secure Enclave + biometric enforcement  
  – Rotation-safe key lifecycle

- `PanicModeCore.swift`  
  – Dual vault system (Primary + Decoy)  
  – Emergency zeroization & redirection  
  – Non-forensic decoy behaviour

### 🚨 App Integrity & Hardening
- `JailbreakDetection.swift`  
  – High-signal jailbreak heuristics  
  – FS probe, sandbox anomaly detection  
  – No private APIs

- `AntiTampering.swift`  
  – Binary integrity checks  
  – Code signature validation  
  – App environment sanity checks

### 🔏 Auditable Logging / Validation
- `SecureLogging.swift`  
  – Ephemeral in-memory logging  
  – No disk persistence  
  – Redacted event structures

- `CryptoValidation.swift`  
  – Known-answer tests (KATs)  
  – Integrity + regression validation for crypto ops

---

## 🧱 Architectural Documentation

NuDefndr contains detailed in-repo security documentation:

- `SECURITY.md` — Security policies & cryptographic commitments  
- `PERFORMANCE.md` — Performance architecture, throughput profiles  
- `THREAT_MODEL.md` — Complete threat surface: device, OS, user, attacker classes  
- `SecurityArchitecture.md` — High-level vault + encryption flow diagrams  

These documents allow third-party engineers and security researchers to **verify NuDefndr’s privacy claims** without exposing any proprietary app logic.

---

## 🛡 Security Architecture Overview

### 🔐 Vault Encryption
- AES-256 + ChaCha20-Poly1305  
- Randomized nonces  
- Per-install unique keys derived from Secure Enclave  
- No plaintext ever written to disk

### 🔏 Panic Mode
- Decoupled decoy vault  
- Emergency PIN triggers vault switch  
- Designed to withstand casual inspection, not forensic extraction

### 🔑 Key Management
- Device-bound  
- Biometric-protected  
- Secure Enclave lifecycle with automatic invalidation on device changes

---

## 🧪 Independent Verification

Security researchers and auditors can confirm:

- **No network requests exist in the analysis or vault subsystem**  
- **Image data is never uploaded, cached externally, or transmitted**  
- **Vault data cannot be decrypted without the Secure Enclave key**  
- **Panic Mode cannot reveal primary vault contents**  
- **Tampering attempts are detectable at runtime**

This repo intentionally allows **external verification without exposing proprietary logic** from the full NuDefndr app.

---

## 📄 License

Released under the MIT License. See `LICENSE` for details.

---

## ⚠️ Disclaimer

This repository exposes **core architectural components** for transparency, education, and privacy verification.  
It is **not** the full production NuDefndr app and cannot be compiled into a standalone build.

Dro1d Labs retains all rights to the NuDefndr app and its proprietary assets.