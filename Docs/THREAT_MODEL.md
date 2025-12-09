# NuDefndr Threat Model

## Document Scope

This document analyzes potential security threats to NuDefndr's privacy architecture and outlines our defensive strategies.

## Assets Under Protection

### Critical Assets
1. **User Photos** - Sensitive image data in device photo library
2. **Vault Content** - Encrypted photos stored in app vault
3. **Encryption Keys** - Symmetric keys protecting vault data
4. **Authentication Credentials** - PINs, biometric templates, panic codes
5. **Analysis Results** - Detection metadata for flagged content

### Secondary Assets
6. **App Preferences** - User settings and configuration
7. **Scan History** - Timestamp data, skip counters
8. **Decoy Vault** - Panic mode alternative storage

## Trust Boundaries

┌─────────────────────────────────────────────────┐
│           iOS Sandbox (Trust Boundary)          │
│  ┌──────────────────────────────────────────┐  │
│  │         NuDefndr App Process             │  │
│  │                                          │  │
│  │  ┌────────────┐      ┌────────────┐    │  │
│  │  │  Analysis  │      │   Vault    │    │  │
│  │  │  Engine    │─────▶│  Storage   │    │  │
│  │  └────────────┘      └────────────┘    │  │
│  │         │                    │          │  │
│  │         ▼                    ▼          │  │
│  │  ┌────────────┐      ┌────────────┐    │  │
│  │  │  Photos    │      │  Keychain  │    │  │
│  │  │  Library   │      │  (Keys)    │    │  │
│  │  └────────────┘      └────────────┘    │  │
│  └──────────────────────────────────────────┘  │
│                                                 │
│  Hardware: Secure Enclave (Key Storage)        │
└─────────────────────────────────────────────────┘
         ▲                          ▲
         │                          │
    Network (DENIED)          Backup (Encrypted)
```

## Threat Actors

### TA-1: Opportunistic Attacker
- **Capability:** Basic technical skills
- **Motivation:** Access to sensitive photos (ex-partner, colleague, etc.)
- **Access:** Physical device access, knows passcode
- **Goals:** View vault contents, export photos

### TA-2: Sophisticated Adversary
- **Capability:** Advanced technical skills, forensic tools
- **Motivation:** Data extraction, evidence gathering
- **Access:** Physical device, possibly unlocked
- **Goals:** Full data extraction, timeline reconstruction

### TA-3: Coercion Scenario
- **Capability:** Physical coercion/threats
- **Motivation:** Force user to unlock vault
- **Access:** Device + coerced user
- **Goals:** Access to real vault (not decoy)

### TA-4: Malicious App (Same Device)
- **Capability:** iOS sandbox escape attempt
- **Motivation:** Data exfiltration
- **Access:** Running on same device
- **Goals:** Memory scraping, IPC exploitation

### TA-5: Network Adversary
- **Capability:** Man-in-the-middle, traffic analysis
- **Motivation:** Intercept sensitive data
- **Access:** Network-level
- **Goals:** Capture photo data in transit

## Threat Scenarios

### T-1: Physical Device Access (Unlocked)

**Threat:** Attacker with unlocked device attempts to access vault

**Mitigations:**
- ✅ Biometric authentication required (Face ID/Touch ID)
- ✅ PIN fallback with rate limiting
- ✅ Auto-lock after 30s inactivity
- ✅ Privacy blur for app switcher
- ✅ Panic PIN for coercion (accesses decoy)

**Residual Risk:** LOW  
**Rationale:** Multiple authentication layers, panic mode provides plausible deniability

---

### T-2: Vault Data Extraction (Device Backup)

**Threat:** Attacker extracts encrypted vault from device backup

**Mitigations:**
- ✅ Device-specific key derivation (UDID-bound)
- ✅ AES-256 + ChaCha20-Poly1305 encryption
- ✅ Keys stored in hardware-backed keychain
- ✅ `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`

**Residual Risk:** LOW  
**Rationale:** Keys cannot be extracted from backup, device-binding prevents cross-device decryption

---

### T-3: Memory Dump Analysis

**Threat:** Sophisticated attacker dumps app memory, searches for keys/data

**Mitigations:**
- ✅ Secure memory clearing on deallocation
- ✅ Keys held in memory only during active operations
- ✅ Automatic memory purge on background
- ⚠️ iOS memory protection (partial - process must be trusted)

**Residual Risk:** MEDIUM  
**Rationale:** iOS provides process isolation, but sophisticated forensic tools may scrape memory if device is compromised

---

### T-4: Cryptographic Weakness

**Threat:** Encryption algorithm or implementation vulnerability

**Mitigations:**
- ✅ Industry-standard algorithms (AES-256, ChaCha20-Poly1305)
- ✅ Apple CryptoKit framework (vetted implementation)
- ✅ Hardware-accelerated where available
- ✅ No custom crypto implementations

**Residual Risk:** VERY LOW  
**Rationale:** Using proven, audited cryptographic primitives from Apple

---

### T-5: Jailbreak/Rooted Device

**Threat:** Attacker runs app on jailbroken device to bypass security

**Mitigations:**
- ⚠️ No active jailbreak detection (may be added)
- ✅ Relies on iOS sandbox integrity
- ✅ Secure Enclave unavailable on jailbroken devices (degrades to software crypto)

**Residual Risk:** HIGH (on jailbroken devices)  
**Rationale:** Jailbreak fundamentally breaks iOS security model; app cannot fully protect against this

**Note:** Jailbroken environments are **explicitly out of scope** per security policy

---

### T-6: Network Data Exfiltration

**Threat:** Sensitive data transmitted over network, intercepted by adversary

**Mitigations:**
- ✅ Zero network activity during analysis
- ✅ No telemetry, analytics, or crash reporting with user data
- ✅ Network code isolated from analysis pipeline
- ✅ Auditable via proxy/packet capture

**Residual Risk:** NONE  
**Rationale:** No sensitive data leaves device, verifiable by users

---

### T-7: Side-Channel Analysis

**Threat:** Timing attacks or power analysis to extract keys

**Mitigations:**
- ✅ Constant-time comparison for PIN validation
- ✅ Hardware-based crypto (resistant to software timing attacks)
- ⚠️ Power analysis impractical (requires physical access + specialized hardware)

**Residual Risk:** VERY LOW  
**Rationale:** Attacks require physical access and specialized equipment; not practical for target threat actors

---

### T-8: Social Engineering / Panic Mode Bypass

**Threat:** Attacker coerces user into providing real PIN instead of panic PIN

**Mitigations:**
- ✅ Decoy vault with plausible content
- ✅ Identical UI/UX for both vaults
- ⚠️ User training required (set up decoy properly)

**Residual Risk:** MEDIUM  
**Rationale:** Effectiveness depends on user setup and attacker sophistication; works against opportunistic attackers

---

### T-9: iOS/macOS Vulnerability Exploitation

**Threat:** Zero-day exploit in iOS allows sandbox escape

**Mitigations:**
- ⚠️ Relies on iOS security model integrity
- ✅ Defense-in-depth (encryption, key isolation)
- ✅ Rapid response to OS updates

**Residual Risk:** LOW  
**Rationale:** Apple's track record is strong; we layer additional protections beyond OS sandbox

---

### T-10: Supply Chain Attack

**Threat:** Malicious code injected during build/distribution

**Mitigations:**
- ✅ App Store code signing (Apple verification)
- ✅ Open-source core components (auditable)
- ✅ Reproducible builds (planned)
- ⚠️ Dependency audit (manual, periodic)

**Residual Risk:** LOW  
**Rationale:** Apple's notarization + open-source critical paths reduce attack surface

---

## Security Controls Matrix

| Threat Scenario | Confidentiality | Integrity | Availability | Priority |
|-----------------|-----------------|-----------|--------------|----------|
| T-1: Physical Access | ✅ STRONG | ✅ STRONG | ✅ STRONG | HIGH |
| T-2: Backup Extract | ✅ STRONG | ✅ STRONG | N/A | HIGH |
| T-3: Memory Dump | ⚠️ MEDIUM | ✅ STRONG | N/A | MEDIUM |
| T-4: Crypto Weakness | ✅ STRONG | ✅ STRONG | N/A | HIGH |
| T-5: Jailbreak | ❌ WEAK | ❌ WEAK | N/A | LOW* |
| T-6: Network Exfil | ✅ MAXIMUM | ✅ MAXIMUM | N/A | CRITICAL |
| T-7: Side-Channel | ✅ STRONG | N/A | N/A | LOW |
| T-8: Panic Bypass | ⚠️ MEDIUM | N/A | N/A | MEDIUM |
| T-9: iOS 0-day | ⚠️ MEDIUM | ⚠️ MEDIUM | N/A | LOW* |
| T-10: Supply Chain | ✅ STRONG | ✅ STRONG | N/A | MEDIUM |

*Out of scope per security policy

## Attack Surface Analysis

### Entry Points
1. **Photo Library Access** - Read-only, Apple framework
2. **Vault UI** - Authentication required
3. **Settings UI** - App preferences (low sensitivity)
4. **Share Extension** - Redaction tools (no vault access)

### Data Flow

```
[Photos Library] ─(read)─▶ [Analysis Engine] ─(detect)─▶ [Results]
                                                              │
                                                              ▼
[Keychain Keys] ◀─(decrypt)─ [Vault Storage] ◀─(encrypt)─ [User Action]
```

**Key Insight:** Analysis and vault are separate pipelines; compromise of one doesn't compromise the other.

## Defense in Depth Layers

1. **iOS Sandbox** - Process isolation, limited filesystem access
2. **Encryption** - AES-256 + ChaCha20-Poly1305 for vault
3. **Key Protection** - Hardware-backed keychain, biometric gating
4. **Authentication** - Multi-factor (biometric + PIN)
5. **Panic Mode** - Decoy vault for coercion scenarios
6. **Privacy Blur** - UI obfuscation in app switcher
7. **Audit Logging** - Security-relevant events logged (local only)

## Compliance & Standards

- **OWASP MASVS**: Level 2 (Defense-in-Depth)
- **NIST Cybersecurity Framework**: Identify, Protect, Detect
- **FIPS 140-2**: Level 1 compliant algorithms
- **GDPR**: Data minimization, user control, no tracking

## Future Enhancements

### Roadmap (Priority Order)

1. **Jailbreak Detection** (Medium Priority)
   - Detect compromised environments
   - Warn user or degrade gracefully

2. **Secure Boot Verification** (Low Priority)
   - Verify app binary integrity on launch
   - Detect tampering attempts

3. **Hardware Security Module** (Research)
   - Secure Enclave deeper integration
   - Key generation inside hardware

4. **Reproducible Builds** (High Priority)
   - Allow independent verification of binaries
   - Publish build instructions

## Conclusion

NuDefndr's threat model prioritizes **realistic attack scenarios** over theoretical edge cases. We focus defense resources on:

1. **Physical device access** (most likely)
2. **Network exfiltration** (most catastrophic)
3. **Coercion scenarios** (unique attack vector)

Our architecture provides **strong protection** against opportunistic attackers (TA-1) and **reasonable protection** against sophisticated adversaries (TA-2) given the constraints of the iOS platform.

**Last Updated:** December 2025  
**Version:** 2.0  
**Next Review:** March 2026
```
