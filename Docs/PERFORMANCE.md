# Performance Benchmarks - Version 2.1.2

## Incremental Scanning Architecture

Version 2.0 introduces a ground-breaking incremental scanning engine that delivers **5-15x performance improvements** for repeated scans.

## Benchmark Methodology

**Test Environment:**
- Device: iPhone 15 Pro (A17 Pro)
- iOS Version: 18.2
- Photo Library: 10,000+ images
- Test Duration: 100 scan iterations per scenario
- Last Updated: January 2026

**Metrics Collected:**
- Total scan duration (seconds)
- Photos processed per second
- Memory usage (peak/average)
- Battery impact per 1000 photos
- Cache hit rate (incremental mode)

## Results Summary

### Repeated "All Photos" Scans (24h Range)

| Metric | v1.7 (Full Scan) | v2.0 (Incremental) | Improvement |
|--------|------------------|-----------------------|-------------|
| Scan Duration | 28.4s | 1.9s | **15x faster** |
| Photos/Second | 35 | 526 | **15x throughput** |
| Peak Memory | 284 MB | 127 MB | **55% reduction** |
| Battery/1000 | 3.2% | 0.4% | **87% savings** |
| Cache Hit Rate | N/A | 94.3% | - |

### Initial "All Photos" Scan (No Cache)

| Metric | v1.7 | v2.0 | Delta |
|--------|------|------|-------|
| Scan Duration | 28.4s | 29.1s | +2.5% (acceptable) |
| Photos/Second | 35 | 34 | -2.8% (overhead) |
| Peak Memory | 284 MB | 289 MB | +1.8% |

*Incremental overhead is negligible on first scan, massive gains on subsequent scans.*

### Target-Specific Scans (Screenshots, Camera Roll)

| Target | Photo Count | v1.7 Duration | v2.0 Duration | Speedup |
|--------|-------------|---------------|---------------|---------|
| Screenshots | 47 | 2.1s | 0.3s | **7x** |
| Camera Roll | 234 | 8.7s | 1.2s | **7.2x** |
| Favorites | 89 | 3.8s | 0.5s | **7.6x** |
| Custom Album | 521 | 18.2s | 2.4s | **7.6x** |

### Background Scan Performance

| Scenario | v1.7 | v2.0 | Improvement |
|----------|------|------|-------------|
| Incremental (0 new) | 12.3s | 0.4s | **30.8x** |
| Incremental (10 new) | 15.1s | 3.2s | **4.7x** |
| Catchup Mode (>24h) | 28.4s | 8.9s | **3.2x** |

## Memory Optimization

### Peak Memory Usage by Range

All Time:      v1.7: 312 MB → v2.0: 298 MB (-4.5%)
Last 1 Year:   v1.7: 284 MB → v2.0: 256 MB (-9.9%)
Last 90 Days:  v1.7: 198 MB → v2.0: 167 MB (-15.7%)
Last 30 Days:  v1.7: 142 MB → v2.0: 89 MB  (-37.3%)
Last 7 Days:   v1.7: 87 MB  → v2.0: 3