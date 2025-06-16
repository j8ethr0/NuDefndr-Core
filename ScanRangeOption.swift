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
