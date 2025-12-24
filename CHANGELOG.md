# Changelog

All notable changes to NuDefndr Core Privacy Components are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.5] - 2025-12-24

### Enhancements:
├─ Extended jailbreak detection engine
├─ Platform-aware security analysis (iOS/macOS)
├─ Improved device integrity reporting
├─ Mac Catalyst platform differentiation
└─ Contextual security notices per platform


## [2.1.2] - 2025-12-12

### Added
- Enhanced vault organization with smart date filtering
- Persistent sort preferences (newest/oldest first)
- Quick date range filters (All, Last 7 Days, Last Month, Last 3 Months)
- Section headers with automatic date grouping (Today, Yesterday, This Week, etc.)
- "Select All Visible" button for filtered vault items
- Advanced Redaction Toolkit with three styles: Blur, Pixelate, Black Box
- Stealth Theme with pure monochrome aesthetic

### Improved
- Background scan reliability with adaptive catchup mode
- Vault UX for managing hundreds of photos efficiently
- Device-aware concurrency for A17+ thumbnail prefetching
- Memory management for large vault operations

### Performance
- 6 concurrent thumbnail requests on A17+ devices (3 on older hardware)
- Optimized vault filtering with computed properties
- Reduced memory footprint during batch operations

## [2.0.0] - 2025-11-20

### Major Changes
- **Unified Incremental Scanning Architecture** - Revolutionary performance improvements
- Manual scans of "All Photos" now use smart incremental logic
- Unified timestamp system replaces separate manual/auto timestamps

### Performance Gains
- **5-15x faster** repeated "All Photos" scans (28s → 1.9s typical)
- **87% battery savings** for background operations
- **60% memory reduction** for short-range scans
- Target-specific scans (Screenshots, Albums) maintain full coverage

### Added
- Force Full Rescan option in Settings
- Automatic migration from legacy timestamp system
- Enhanced skip logic with clear logging
- Backward compatibility for one version cycle

### Security
- Strengthened background task diagnostics
- Improved scan completion detection
- Race condition elimination in automatic scans

## [1.7.0] - 2025-10-25

### Added
- Unified scan architecture for manual and automatic scans
- Incremental scanning for "All Photos" target
- Full scan mode for specific targets (Screenshots, Camera Roll, etc.)
- Detailed architecture documentation

### Changed
- Single `lastSuccessfulScanDate` timestamp for all scan types
- Improved skip logic based on photo modification dates
- Enhanced logging for scan operations

### Fixed
- Timestamp inconsistencies between manual and automatic scans
- Memory usage during large library scans

## [1.6.7] - 2025-09-10

### Fixed
- Auto-scan timestamp not refreshing on completion (critical fix)
- Background task timestamp staleness causing range flip-flopping
- Concurrency gate false positives

### Improved
- Guaranteed auto-scan timestamp updates in all completion paths
- Enhanced background task diagnostics and logging
- Timestamp consistency across app lifecycle

## [1.6.5] - 2025-08-28

### Added
- Independent automatic scan timestamp tracking
- Adaptive catchup mode for delayed background tasks (>24h → 7-day scan)
- Enhanced automatic scan logging
- Non-intrusive toast notifications for auto-scans

### Improved
- Manual scan independence from automatic scan timing
- True incremental scanning for auto-scans
- Background task scheduling reliability

## [1.6.0] - 2025-07-15

### Added
- Production-ready background task scheduling (30-min intervals)
- Smart network requirement detection based on iCloud usage
- Watchdog fallback system (max once per week)
- A17+ thumbnail prefetching with parallelized loading

### Improved
- Background execution reliability on iOS 18+
- Network constraint logic for 90% of users
- Performance on latest hardware
- Thumbnail cache management

### Changed
- Minimum background task interval from 10min to 30min (iOS-friendly)
- Single-pending-request discipline maintained
- Reschedule timing: 3h success, 1h failure

## [1.5.0] - 2025-05-20

### Added
- Panic Mode architecture with dual-vault system
- Emergency PIN triggers vault switching
- Decoy vault with plausible content support
- Hardware-backed encryption key storage

### Security
- Secure Enclave integration for key derivation
- Biometric authentication for vault access
- Privacy blur for app switcher
- Auto-lock after 30s inactivity

## [1.4.0] - 2025-03-15

### Added
- ChaCha20-Poly1305 encryption alongside AES-256
- PBKDF2 key derivation with 100K+ iterations
- Key rotation and forward secrecy support
- Entropy validation and NIST compliance checks

### Security
- FIPS 140-2 Level 1 compliance where supported
- Constant-time PIN comparison
- Anti-tampering validation
- Jailbreak detection (10 detection vectors)

## [1.3.0] - 2025-01-10

### Added
- Apple SensitiveContentAnalysis framework integration (iOS 17+)
- On-device NSFW content detection
- Zero-knowledge architecture
- Batch scanning with adaptive throttling

### Privacy
- Zero network transmission during analysis
- Local-only ML processing
- No telemetry or analytics in detection pipeline
- Auditable privacy guarantees

## [1.2.0] - 2024-11-05

### Added
- Multi-range scan support (7 days, 30 days, 90 days, 1 year, all time)
- Smart scan target filtering (Screenshots, Camera Roll, Favorites, etc.)
- Memory usage estimation per scan range
- Performance metrics and efficiency tracking

## [1.1.0] - 2024-09-01

### Added
- Initial vault encryption implementation
- AES-256 encryption for sensitive photos
- Basic keychain integration
- Photo library access with privacy controls

## [1.0.0] - 2024-07-01

### Added
- Initial release of NuDefndr Core Privacy Components
- Basic sensitive content detection wrapper
- Security documentation
- MIT License

---

## Versioning Policy

- **Major version (X.0.0)**: Breaking changes, new architecture
- **Minor version (X.Y.0)**: New features, backward-compatible improvements
- **Patch version (X.Y.Z)**: Bug fixes, security patches

## Roadmap

### Planned for 2.2.0
- Jailbreak detection enhancements
- Reproducible builds for audit verification
- Enhanced hardware security module integration
- Improved performance monitoring

### Under Consideration
- Secure boot verification
- Multi-layer encryption profiles
- Advanced threat intelligence integration
- Extended platform support (iPadOS optimizations)

---

**Repository:** [github.com/defndr-labs/NuDefndr-Core](https://github.com/defndr-labs/NuDefndr-Core)  
**Website:** [nudefndr.com](https://nudefndr.com)  
**Developer:** Dro1d Labs Limited