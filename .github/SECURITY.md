# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| 2.1.x   | ✅        |
| 2.0.x   | ✅        |
| 1.7.x   | ⚠️ Limited |
| < 1.7   | ❌        |

## Reporting a Vulnerability

**We take security seriously.**

If you discover a security vulnerability in NuDefndr Core or the production app:

1. **Do NOT** open a public GitHub issue
2. Email: security@nudefndr.com
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact assessment
   - Suggested fix (if available)
   - Affected versions

**Response Timeline:**
- Initial response: Within 48 hours
- Status update: Within 7 days
- Fix timeline: Depends on severity
  - Critical: 7-14 days
  - High: 14-30 days
  - Medium: 30-60 days
  - Low: 60-90 days

## Severity Levels

**Critical:**
- Remote code execution
- Vault decryption without authentication
- Authentication bypass
- Mass data exfiltration

**High:**
- Privilege escalation
- Sensitive data exposure
- Cryptographic weakness
- Jailbreak detection bypass

**Medium:**
- Information disclosure
- Denial of service
- Logic errors affecting security

**Low:**
- Best practice violations
- Non-sensitive information leaks
- Minor cryptographic improvements

## Security Guarantees

- ✅ **No data leaves the device** during photo analysis
- ✅ **Hardware-backed encryption** for vault storage
- ✅ **Open-source core components** for audit
- ✅ **Regular internal security reviews**
- ✅ **FIPS-aligned cryptographic algorithms**

## Out of Scope

- Jailbroken/rooted devices (explicitly unsupported)
- Physical device access with unlocked state
- Social engineering attacks
- iOS/macOS zero-day exploits
- Attacks requiring Secure Enclave compromise

## Security Hall of Fame

_No security disclosures have been submitted yet._

We will recognize researchers who responsibly disclose vulnerabilities:
- Name/handle listed here (with permission)
- Public credit in release notes
- Acknowledgment on nudefndr.com

## Compliance

**Standards:**
- FIPS 140-2 Level 1 (where supported)
- OWASP MASVS Level 2
- NIST Cybersecurity Framework

**Privacy:**
- GDPR compliant (no data collection)
- No analytics or telemetry in detection pipeline
- 100% local processing

## Cryptographic Disclosure

**Algorithms in use:**
- AES-256-GCM (encryption)
- ChaCha20-Poly1305 (encryption)
- PBKDF2-HMAC-SHA256 (key derivation, 100K+ rounds)
- SHA-256 (hashing)
- HKDF-SHA256 (key rotation)

**Key storage:**
- iOS Keychain with `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`
- Secure Enclave where available
- Biometric protection required

## Known Limitations

**Panic Mode:**
- Not forensically secure
- Designed for casual inspection only
- Advanced forensics may detect dual-vault

**Jailbreak Detection:**
- Bypass possible with kernel-level access
- 10 detection vectors, not exhaustive
- Sophisticated attackers can evade

**Memory Security:**
- iOS provides process isolation
- Sophisticated memory forensics may extract keys from running process
- Keys cleared on app background/termination

## Security Updates

**December 2025 (v2.1.2):**
- Enhanced vault organization
- Improved background task reliability
- Performance optimizations

**November 2025 (v2.0.0):**
- Unified incremental scanning
- Race condition fixes
- Timestamp management improvements

**See [CHANGELOG.md](../CHANGELOG.md) for full history**

---

**Last Updated:** December 12, 2025  
**Version:** 2.1.2  
**Contact:** security@nudefndr.com  
**Website:** https://nudefndr.com