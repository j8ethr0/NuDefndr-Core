# Security Policy

## Supported Versions

| Version | Supported |
|--------|-----------|
| 2.1.x  | ✔️         |
| 2.0.x  | ✔️         |
| 1.7.x  | ⚠️ Limited |
| < 1.7  | ❌         |

## Security Architecture

NuDefndr uses a layered, local-only security design:

- **On-Device Analysis** — No network transmission during sensitive detection
- **Modern Encryption** — AES-256 and ChaCha20-Poly1305 for vault storage
- **Hardware-Backed Keys** — Secure Enclave when available
- **Biometric Access** — Face ID / Touch ID for vault unlock
- **Panic Mode** — Dual-vault architecture with optional decoy mode

## Threat Model

We assume:

1. Device has a passcode enabled  
2. iOS/macOS integrity is intact  
3. Device is not jailbroken  
4. Secure Enclave is available on supported devices  

Out-of-scope:

- Unlocked stolen devices  
- Jailbroken/rooted devices  
- Full physical compromise  
- OS-level zero-day exploits  

## Reporting a Vulnerability

We take all security issues seriously.

**Do not open a public issue.**

Report privately to: 
dev@nudefndr.com

Include:

- Description of the vulnerability  
- Steps to reproduce  
- Impact assessment  
- Affected versions  
- Suggested fix (optional)

### Response Deadlines

- **Initial acknowledgment:** within 48 hours  
- **Assessment:** 7 days  
- **Fix timelines:**  
  - Critical: 7–14 days  
  - High: 14–30 days  
  - Medium: 30–60 days  

## Severity Levels

- **Critical** — RCE, vault decryption, auth bypass  
- **High** — Privilege escalation, sensitive data exposure  
- **Medium** — Information disclosure, DoS  
- **Low** — Best-practice issues  

## Security Hall of Fame

_No security disclosures have been submitted yet._

## Compliance

- FIPS-aligned algorithms where supported  
- Hardware-backed keychain with biometrics  
- No telemetry, analytics, or tracking  
- Open-source crypto components for audit  

## Security Update Log

### 2.1.7 — January 2026
- **Documentation Accuracy** - Removed references to unimplemented features
- **Repository Maintenance** - Updated all dates and version numbers
- **Security Architecture** - Clarified key management lifecycle

### 2.1.3 — December 2025
- **Vault Metrics Privacy Controls** - Optional item count display with Pro feature gating
- **Enhanced Lock Screen Architecture** - User-controlled metadata visibility
- **Performance Optimizations** - Fast vault queries without decryption overhead

### 2.1.2 — December 2025
- Enhanced vault organization with smart filtering
- Advanced Redaction Toolkit (Blur, Pixelate, Black Box)
- Stealth Theme implementation
- Device-aware concurrency optimizations

### 2.0 — November 2025
- Improved background-task stability
- Unified scan result pipeline
- Better timestamp handling for incremental scans

### 1.7.0 — October 2025
- Unified scanning architecture
- Reduced race conditions in scan completion
- Improved timestamp migration reliability

---

**Last Updated:** January 2, 2026  
**Version:** 2.1.7
**Contact:** security@nudefndr.com  
Website: https://nudefndr.com