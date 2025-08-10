// Copyright (c) 2025 Dro1d Labs Limited
// Released under the MIT License. See LICENSE file for details.
//
// NuDefndr App - Core Privacy Component
// App Website: https://nudefndr.com
// Developer: Dro1d Labs

import Foundation

enum ScanRangeOption: String, CaseIterable, Identifiable {
	case last7Days = "Last 7 Days"
	case last30Days = "Last 30 Days"
	case last90Days = "Last 90 Days"
	case last1Year = "Last Year"
	case allTime = "All Time"

	var id: String { self.rawValue }

	var isFree: Bool {
		switch self {
		case .last7Days:
			return true
		default:
			return false 
		}
	}

	// data minimization
	var description: String {
		switch self {
		case .last7Days: return "Scans photos modified in the last 7 days (Free)"
		case .last30Days: return "Scans photos modified in the last 30 days (Pro)"
		case .last90Days: return "Scans photos modified in the last 90 days (Pro)" 
		case .last1Year: return "Scans photos modified in the last year (Pro)"
		case .allTime: return "Scans entire photo library (Pro)"
		}
	}
}

let freeScanRangeOption = ScanRangeOption.last7Days

extension ScanRangeOption {
  
  static func customRange(from startDate: Date, to endDate: Date) -> CustomScanRange {
	  return CustomScanRange(startDate: startDate, endDate: endDate)
  }
  
  /// Estimated scan duration based on photo library size
  func estimatedDuration(for photoCount: Int) -> TimeInterval {
	  let baseTimePerPhoto: TimeInterval = 0.5 // 500ms per photo
	  let rangeMultiplier: Double
	  
	  switch self {
	  case .last7Days: rangeMultiplier = 0.1
	  case .last30Days: rangeMultiplier = 0.3
	  case .last90Days: rangeMultiplier = 0.6
	  case .last1Year: rangeMultiplier = 0.8
	  case .allTime: rangeMultiplier = 1.0
	  }
	  
	  return baseTimePerPhoto * Double(photoCount) * rangeMultiplier
  }
  
  /// Memory usage estimation
  var estimatedMemoryUsage: MemoryUsageLevel {
	  switch self {
	  case .last7Days: return .low
	  case .last30Days: return .medium
	  case .last90Days, .last1Year: return .high
	  case .allTime: return .maximum
	  }
  }
}

struct CustomScanRange {
  let startDate: Date
  let endDate: Date
  let id = UUID()
  
  var description: String {
	  let formatter = DateFormatter()
	  formatter.dateStyle = .medium
	  return "Custom: \(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
  }
  
  var isFree: Bool { false }
}

enum MemoryUsageLevel: String, CaseIterable {
  case low = "Low (< 100MB)"
  case medium = "Medium (100-500MB)"
  case high = "High (500MB-1GB)"
  case maximum = "Maximum (> 1GB)"
  
  var color: String {
	  switch self {
	  case .low: return "green"
	  case .medium: return "yellow"  
	  case .high: return "orange"
	  case .maximum: return "red"
	  }
  }
}

struct ScanPerformanceMetrics {
  let scanRange: ScanRangeOption
  let photosAnalyzed: Int
  let totalDuration: TimeInterval
  let averageTimePerPhoto: TimeInterval
  let peakMemoryUsage: Int
  let sensitiveContentFound: Int
  
  var efficiency: ScanEfficiency {
	  if averageTimePerPhoto < 0.3 { return .excellent }
	  if averageTimePerPhoto < 0.6 { return .good }
	  if averageTimePerPhoto < 1.0 { return .fair }
	  return .poor
  }
}

enum ScanEfficiency: String {
  case excellent = "Excellent"
  case good = "Good"
  case fair = "Fair" 
  case poor = "Needs Optimization"
}

