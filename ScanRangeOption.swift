// Copyright (c) 2025 Fergal Monahan
// Released under the MIT License. See LICENSE file for details.
//
// NuDefndr App - Core Privacy Component
// App Website: https://nudefndr.com
// Developer: https://dro1d.org

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

	var startDate: Date? {    // *redacted*
		let calendar = Calendar.current
		switch self {
		case .last7Days: return calendar.date(byAdding: .day, value: -7, to: Date())
		case .last30Days: return calendar.date(byAdding: .day, value: -30, to: Date())
		case .last90Days: return calendar.date(byAdding: .day, value: -90, to: Date())
		case .last1Year: return calendar.date(byAdding: .year, value: -1, to: Date())
		case .allTime: return nil
		}
	}
}

let freeScanRangeOption = ScanRangeOption.last7Days
