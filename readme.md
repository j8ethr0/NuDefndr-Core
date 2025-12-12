![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)
![iOS](https://img.shields.io/badge/iOS-18+-lightgrey.svg)
![Architecture](https://img.shields.io/badge/On--Device-ML-blue.svg)
![Privacy](https://img.shields.io/badge/Privacy-100%25%20Local-green.svg)
![Security](https://img.shields.io/badge/Security-Hardened-black.svg)
![Status](https://img.shields.io/badge/Status-Active%20Development-brightgreen.svg)

# NuDefndr — Core Privacy Components

NuDefndr is an on-device sensitive-content analysis toolkit for iOS.  
This repository contains auditable, production-oriented components extracted from the NuDefndr app that are intended for transparency, security review, and safe reuse in privacy-first applications.

**Website:** https://nudefndr.com  
**Maintainers:** @j8ethr0, @dro1d-labs

---

## At a glance

NuDefndr separates responsibilities into small, well-scoped modules:
NuDefndr Core
├─ Security/
│  ├─ AntiTampering.swift
│  ├─ JailbreakDetection.swift
│  ├─ SensitiveContentService.swift
│  └─ SecureLogging.swift
├─ Vault/
│  ├─ KeychainSecure.swift
│  └─ VaultCrypto.swift
├─ PanicMode/
│  ├─ PanicModeEngine.swift
│  └─ PanicModeConfig.swift
├─ Performance/
│  ├─ PerformanceMonitor.swift
│  └─ ScanRangeOption.swift
└─ Tests/

---

## Privacy & Security Commitments

- **On-device processing only** — analysis runs locally; no image data is transmitted.  
- **Hardware-backed keys** — where available, keys are derived/stored with Secure Enclave.  
- **Minimal telemetry** — no user-identifying telemetry or analytics in the analysis pipeline.  
- **Auditable design** — documentation and threat model included for independent review.

---

## Modules (brief)

- **SensitiveContentService** – Apple framework wrapper and scan orchestration.  
- **VaultCrypto / KeychainSecure** – encrypted storage primitives and secure key lifecycle.  
- **JailbreakDetection / AntiTampering** – environment sanity checks and runtime integrity utilities (informational; designed for graceful degradation).  
- **PanicModeCore** – dual-vault flow and emergency UX controls.  
- **SecureLogging** – ephemeral, redacted logs for diagnostics.

---

## Docs & Verification

See `Docs/` for:
- `SECURITY.md` — security policy & disclosure process  
- `THREAT_MODEL.md` — concise threat analysis and controls  
- `SecurityArchitecture.md` — architecture diagrams and flow notes  
- `PERFORMANCE.md` — benchmarks and scan behaviour

---

## 👩‍💻 Core Engineering

- **@dro1d-labs** — Security R&D, hardening, internal diagnostics, and privacy audits  
- **@j8ethr0** — product & platform lead  
- **@chiho630** — Core engineering and security testing  

If you want to contribute, open an issue or pull request. For sensitive security reports, see `SECURITY.md` (private reporting instructions).

---

## License

MIT — see `LICENSE`.