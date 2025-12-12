# Contributing to NuDefndr Core

Thank you for your interest in NuDefndr's privacy and security architecture!

This repository contains **auditable core components** extracted from the production NuDefndr app to enable transparency, security research, and privacy verification.

## 🔒 Repository Purpose

NuDefndr Core serves as:
- **Transparency tool** - Verify our privacy and security claims
- **Security audit resource** - Review cryptographic implementations
- **Educational reference** - Learn about on-device ML and privacy architecture
- **Bug bounty target** - Help us identify security vulnerabilities

## 🤝 How to Contribute

### Security Research & Audits

**We welcome:**
- Cryptographic implementation reviews
- Privacy guarantee verification
- Jailbreak detection effectiveness testing
- Threat model validation
- Side-channel analysis
- Performance benchmarking

**How to contribute:**
1. Review the code in `/Vault`, `/Security`, `/Tests` directories
2. Run validation tests and benchmarks
3. Document findings with reproducible test cases
4. Submit via security email (see below) or open a discussion

### Documentation Improvements

**We accept PRs for:**
- Security documentation enhancements
- Architecture diagram additions
- Threat model expansions
- Performance benchmark updates
- Clearer code comments in audit components

**How to contribute:**
1. Fork the repository
2. Create a feature branch: `git checkout -b improve-threat-docs`
3. Make your changes to `/Docs` or code comments
4. Submit a pull request with clear description

### Reporting Security Issues

**🚨 Do NOT open public issues for security vulnerabilities!**

**Report privately to:**
- Email: security@nudefndr.com
- PGP Key: [Available on request]

**Include:**
- Vulnerability description
- Proof-of-concept (if applicable)
- Steps to reproduce
- Impact assessment
- Affected versions
- Suggested remediation (optional)

**Response timeline:**
- Initial acknowledgment: **Within 48 hours**
- Status update: **Within 7 days**
- Fix timeline: Depends on severity
  - Critical: 7-14 days
  - High: 14-30 days
  - Medium: 30-60 days

### Bug Reports & Feature Requests

**For the production NuDefndr app:**
- Use the in-app feedback mechanism
- Email support@nudefndr.com
- App Store reviews (for public feedback)

**For this repository:**
- Open a GitHub issue for documentation bugs
- Open a discussion for architecture questions
- Security issues via private email only

## ❌ What We Don't Accept

### Pull Requests We Cannot Merge:
- Complete feature implementations (this is an audit repo, not the full app)
- Proprietary algorithm modifications (those remain closed-source)
- UI/UX changes (not applicable to this repo)
- Third-party dependency additions (we maintain minimal dependencies)
- Functionality expansions beyond audit scope

### Why?
This repository is intentionally **incomplete** - it contains auditable privacy/security components only. The production NuDefndr app includes significant additional proprietary logic, UI, and optimizations that are not open-sourced.

## 🧪 Testing Your Contributions

### Run Cryptographic Tests

bash
swift test --filter CryptoTests
```

### Run Security Validation

swift test --filter SecurityTests


swift test --filter PerformanceBenchmarkSuite


### Generate Audit Reports

let auditReport = CryptoValidator.generateAuditReport()
print(auditReport)

let integrityReport = AntiTamperingValidator.generateIntegrityReport()
print(integrityReport)

let jailbreakReport = JailbreakDetector.generateDetectionReport()
print(jailbreakReport)


## 📐 Code Standards

### For Documentation PRs:
- Use clear, technical language
- Include references to standards (NIST, FIPS, OWASP)
- Maintain existing formatting style
- Add diagrams where helpful (ASCII art or Mermaid)

### For Security Research:
- Provide reproducible test cases
- Document environment (iOS version, device, jailbreak status)
- Include performance impact analysis
- Suggest concrete mitigations

## 🏆 Recognition

We maintain a **Security Hall of Fame** in `SECURITY.md` for researchers who responsibly disclose vulnerabilities.

**Eligibility criteria:**
- Responsibly disclosed (private report, not public disclosure)
- Verified and reproducible
- Impact on user privacy or security
- Not previously known or reported

**Recognition includes:**
- Name/handle in Security Hall of Fame
- Public credit in release notes (with permission)
- Acknowledgment on nudefndr.com (optional)

**Note:** We do not currently offer a paid bug bounty program, but we deeply value and recognize security research contributions.

## 📜 Code of Conduct

### Our Standards
- **Respectful communication** - Professional, constructive feedback
- **Responsible disclosure** - Private security reports before public disclosure
- **Constructive criticism** - Focus on improvement, not just pointing out flaws
- **No harassment** - Treat all contributors with respect
- **Privacy respect** - Do not attempt to exfiltrate user data from the production app

### Unacceptable Behavior
- Public disclosure of vulnerabilities before fix
- Harassment or discriminatory language
- Malicious use of discovered vulnerabilities
- Attempting to access user data
- Disruptive or bad-faith contributions

### Enforcement
Violations may result in:
- Warning from maintainers
- Temporary ban from repository
- Permanent ban for severe violations
- Report to GitHub for Terms of Service violations

## 📞 Contact

- **General questions:** dev@nudefndr.com
- **Security reports:** security@nudefndr.com
- **Website:** [nudefndr.com](https://nudefndr.com)
- **App Store:** [NuDefndr on App Store](https://apps.apple.com/app/nudefndr)

## 📄 License

By contributing to this repository, you agree that your contributions will be licensed under the same MIT License that covers the project. See [LICENSE](LICENSE) for details.

---

**Last Updated:** December 12, 2025  
**Maintained by:** Dro1d Labs Limited
```
