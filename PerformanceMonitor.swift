// Copyright (c) 2025 Dro1d Labs Limited
// Released under the MIT License. See LICENSE file for details.
//
// NuDefndr App - Performance Monitoring Component
// App Website: https://nudefndr.com
// Developer: Dro1d Labs

import Foundation
import UIKit

/// Performance monitoring and adaptive throttling system
class PerformanceMonitor {
	static let shared = PerformanceMonitor()
	
	private var thermalState: ProcessInfo.ThermalState = .nominal
	private var totalAnalysisCount: Int = 0
	private var totalAnalysisTime: TimeInterval = 0
	
	private init() {
		observeThermalState()
	}
	
	// MARK: - Thermal Management
	
	private func observeThermalState() {
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(thermalStateChanged),
			name: ProcessInfo.thermalStateDidChangeNotification,
			object: nil
		)
		thermalState = ProcessInfo.processInfo.thermalState
	}
	
	@objc private func thermalStateChanged() {
		thermalState = ProcessInfo.processInfo.thermalState
		print("[Performance] Thermal state: \(thermalStateDescription)")
	}
	
	private var thermalStateDescription: String {
		switch thermalState {
		case .nominal: return "Nominal"
		case .fair: return "Fair"
		case .serious: return "Serious"
		case .critical: return "Critical"
		@unknown default: return "Unknown"
		}
	}
	
	/// Check thermal state and throttle if necessary
	func checkThermalState() async {
		switch thermalState {
		case .serious:
			await Task.sleep(nanoseconds: 250_000_000) // 250ms delay
		case .critical:
			await Task.sleep(nanoseconds: 500_000_000) // 500ms delay
		default:
			break
		}
	}
	
	// MARK: - Adaptive Batch Sizing
	
	/// Determines optimal batch size based on device state
	func adaptiveBatchSize() -> Int {
		switch thermalState {
		case .nominal:
			return 50
		case .fair:
			return 25
		case .serious:
			return 10
		case .critical:
			return 5
		@unknown default:
			return 25
		}
	}
	
	// MARK: - Memory Pressure Detection
	
	func isMemoryPressureHigh() -> Bool {
		// Simple heuristic - can be enhanced with real memory checks
		let usedMemory = reportMemoryUsage()
		return usedMemory > 500_000_000 // 500MB threshold
	}
	
	private func reportMemoryUsage() -> UInt64 {
		var info = mach_task_basic_info()
		var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
		
		let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
			$0.withMemoryRebound(to: integer_t.self, capacity: 1) {
				task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
			}
		}
		
		return kerr == KERN_SUCCESS ? info.resident_size : 0
	}
	
	// MARK: - Performance Metrics
	
	func recordAnalysis(duration: TimeInterval) {
		totalAnalysisCount += 1
		totalAnalysisTime += duration
	}
	
	func averageAnalysisTime() -> TimeInterval {
		guard totalAnalysisCount > 0 else { return 0 }
		return totalAnalysisTime / Double(totalAnalysisCount)
	}
	
	func resetMetrics() {
		totalAnalysisCount = 0
		totalAnalysisTime = 0
	}
	
	// MARK: - GPU Acceleration Detection
	
	enum ComputeBackend {
		case cpu
		case gpu
		case neuralEngine
	}
	
	func detectComputeBackend() -> ComputeBackend {
		// iOS 17+ devices with A17+ chips have Neural Engine
		if #available(iOS 17.0, *) {
			let modelName = UIDevice.current.model
			if modelName.contains("iPhone") {
				// Heuristic: Recent iPhones likely have Neural Engine
				return .neuralEngine
			}
		}
		
		// GPU acceleration available on most modern devices
		return .gpu
	}
	
	// MARK: - Device Capability Assessment
	
	struct DeviceCapabilities {
		let cpuCores: Int
		let totalMemory: UInt64
		let computeBackend: ComputeBackend
		let supportsHardwareCrypto: Bool
	}
	
	func assessDeviceCapabilities() -> DeviceCapabilities {
		let cpuCount = ProcessInfo.processInfo.processorCount
		let totalMemory = ProcessInfo.processInfo.physicalMemory
		let backend = detectComputeBackend()
		let hardwareCrypto = checkHardwareCryptoSupport()
		
		return DeviceCapabilities(
			cpuCores: cpuCount,
			totalMemory: totalMemory,
			computeBackend: backend,
			supportsHardwareCrypto: hardwareCrypto
		)
	}
	
	private func checkHardwareCryptoSupport() -> Bool {
		// Secure Enclave available on A7+ chips (iPhone 5s and later)
		return true // Most modern devices support this
	}
}

// MARK: - Performance Diagnostics

extension PerformanceMonitor {
	func generatePerformanceReport() -> String {
		let capabilities = assessDeviceCapabilities()
		let avgTime = averageAnalysisTime()
		
		return """
		=== Performance Report ===
		Thermal State: \(thermalStateDescription)
		CPU Cores: \(capabilities.cpuCores)
		Total Memory: \(ByteCountFormatter.string(fromByteCount: Int64(capabilities.totalMemory), countStyle: .memory))
		Compute Backend: \(capabilities.computeBackend)
		Hardware Crypto: \(capabilities.supportsHardwareCrypto ? "Available" : "Unavailable")
		Total Analyses: \(totalAnalysisCount)
		Average Time: \(String(format: "%.3f", avgTime))s
		Adaptive Batch: \(adaptiveBatchSize()) items
		==========================
		"""
	}
}