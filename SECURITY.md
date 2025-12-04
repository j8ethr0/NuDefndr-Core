# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 2.0.x   | :white_check_mark: |
| 1.7.x   | :white_check_mark: |
| 1.6.x   | :x:                |
| < 1.6   | :x:                |

## Security Architecture

NuDefndr implements defense-in-depth security architecture:

- **On-Device Analysis Only**: Zero network transmission during sensitive content detection
- **Military-Grade Encryption**: AES-256 + ChaCha20-Poly1305 for vault storage
- **Hardware-Backed Keys**: Secure Enclave integration where available
- **Biometric Protection**: Face ID / Touch ID authentication requirements
- **Panic Mode Architecture**: Dual-vault system with decoy capabilities

## Known Security Considerations

### Threat Model
Our security model assumes:
1. Physical device security (device passcode enabled)
2. iOS/macOS security integrity maintained
3. No jailbreak/rooted environment
4. Secure Enclave availability on supported devices

### Out of Scope
The following are explicitly out of scope:
- Physical device compromise (stolen unlocked device)
- Jailbroken/rooted device environments
- Nation-state adversaries with device-level access
- iOS/macOS zero-day vulnerabilities

## Reporting a Vulnerability

**We take security seriously.** If you discover a security vulnerability, please report it responsibly.

### Reporting Process

1. **DO NOT** create a public GitHub issue
2. Email: security@nudefndr.com
3. Subject: `[SECURITY] Brief Description`
4. Include:
   - Detailed description of the vulnerability
   - Steps to reproduce
   - Affected versions
   - Potential impact assessment
   - Suggested remediation (if available)

### What to Expect

- **Initial Response**: Within 48 hours
- **Assessment**: Within 7 days
- **Resolution Timeline**: Varies by severity (Critical: 7-14 days, High: 14-30 days, Medium: 30-60 days)
- **Disclosure**: Coordinated disclosure after patch release

### Severity Classification

**Critical**: Remote code execution, authentication bypass, vault decryption without credentials  
**High**: Local privilege escalation, sensitive data exposure, panic mode bypass  
**Medium**: Information disclosure, denial of service  
**Low**: Best practice violations, non-exploitable issues

## Security Hall of Fame

We recognize security researchers who responsibly disclose vulnerabilities:

*No vulnerabilities reported yet. Be the first!*

## Bounty Program

While we do not currently offer a formal bug bounty program, we recognize and credit all legitimate security reports. Researchers who discover critical vulnerabilities may be eligible for recognition and rewards on a case-by-case basis.

## Security Best Practices for Users

1. **Enable Device Passcode**: Use strong alphanumeric passcode (minimum 6 digits)
2. **Enable Biometric Auth**: Face ID or Touch ID for vault access
3. **Regular Backups**: Encrypted iCloud or iTunes backups recommended
4. **Panic PIN Setup**: Configure decoy vault for coercion scenarios
5. **Keep Updated**: Install app updates promptly for security patches

## Compliance & Standards

- **Encryption**: FIPS 140-2 Level 1 compliant algorithms where supported
- **Key Storage**: Hardware-backed keychain with biometric protection
- **Privacy**: No telemetry, no analytics, no user tracking
- **Open Source**: Core security components published for audit

## Security Updates Log

### Version 2.0 (December 2025)
- Fixed crash when background tasks run without scan history
- Improved completion detection for automatic background scans
- Enhanced timestamp handling for unified scan system
- Strengthened background task scheduling reliability

### Version 1.7.0 (November 2025)
- Unified scan architecture with incremental optimization
- Improved race condition handling in scan completion
- Enhanced timestamp migration logic

## Contact

- **Security Issues**: security@nudefndr.com
- **General Support**: support@nudefndr.com
- **Website**: https://nudefndr.com

---

*Last Updated: December 2025*  
*Version: 2.0*