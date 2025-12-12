// Copyright (c) 2025 Dro1d Labs Limited
// Released under the MIT License. See LICENSE file for details.
//
// NuDefndr App - Core Privacy Component
// App Website: https://nudefndr.com
// Developer: Dro1d Labs Security Engineering Team
//
// Privacy Guarantee:
// This service performs analysis entirely on-device using Apple’s
// SensitiveContentAnalysis framework. No image data or results ever leave
// the user’s device.

import Foundation
import SensitiveContentAnalysis
import UIKit
import CoreGraphics
import SwiftUI
import os.log

final class SensitiveContentService {

	private let analyzer = SCSensitivityAnalyzer()
	private let logger = Logger(subsystem: "com.nudefndr.core", category: "ContentAnalysis")
	private let performanceMonitor = PerformanceMonitor.shared

	// MARK: - Single Image Analysis

	func analyzeImage(imageData: Data, assetIdentifier: String) async -> Bool {
		await performanceMonitor.checkThermalState()

		guard let uiImage = UIImage(data: imageData),
			  let cgImage = uiImage.cgImage else {
			SecureLogger.warning("Failed to decode image for analysis", category: "SensitiveContent")
			return false
		}

		do {
			let start = Date()
			let result = try await analyzer.analyzeImage(cgImage)
			let duration = Date().timeIntervalSince(start)

			performanceMonitor.recordAnalysis(duration: duration)

			return result.isSensitive
		} catch {
			SecureLogger.error("Image analysis failed: \(error.localizedDescription)", category: "SensitiveContent")
			return false
		}
	}

	// MARK: - URL Based Analysis

	func analyzeImage(at imageURL: URL) async -> Bool {
		var accessGranted = false

		if imageURL.isFileURL {
			accessGranted = imageURL.startAccessingSecurityScopedResource()
			if !accessGranted {
				SecureLogger.warning("SecurityScopedResource access denied", category: "SensitiveContent")
			}
		}

		defer {
			if accessGranted { imageURL.stopAccessingSecurityScopedResource() }
		}

		do {
			let data = try Data(contentsOf: imageURL)
			return await analyzeImage(imageData: data, assetIdentifier: imageURL.absoluteString)
		} catch {
			SecureLogger.error("Failed to load image data: \(error.localizedDescription)",
							   category: "SensitiveContent")
			return false
		}
	}

	// MARK: - Thermal-Aware Batch Analysis

	func analyzeBatchWithThermalAwareness(
		_ urls: [URL],
		progressCallback: @escaping (Double) -> Void
	) async -> [URL: Bool] {

		var results: [URL: Bool] = [:]
		let batchSize = performanceMonitor.adaptiveBatchSize()

		for (index, url) in urls.enumerated() {

			if index % batchSize == 0 {
				await performanceMonitor.checkThermalState()

				if performanceMonitor.isThermalCritical {
					SecureLogger.warning("Thermal critical reached — throttling batch analysis",
										 category: "Thermal")
					await Task.sleep(nanoseconds: 300_000_000)
				}
			}

			let result = await analyzeImage(at: url)
			results[url] = result

			await MainActor.run {
				progressCallback(Double(index + 1) / Double(urls.count))
			}

			if performanceMonitor.isMemoryPressureHigh() {
				await Task.sleep(nanoseconds: 100_000_000)
			}
		}

		return results
	}
}

// MARK: - Extensions

extension SensitiveContentService {

	func analyzeBatch(
		_ urls: [URL],
		progressCallback: @escaping (Double) -> Void
	) async -> [URL: Bool] {

		var results: [URL: Bool] = [:]

		for (index, url) in urls.enumerated() {
			results[url] = await analyzeImage(at: url)

			await MainActor.run {
				progressCallback(Double(index + 1) / Double(urls.count))
			}
		}

		return results
	}

	func analyzeWithMemoryOptimization(
		imageData: Data,
		maxSize: CGSize = CGSize(width: 2048, height: 2048)
	) async -> Bool {

		// Future enhancement: downscale before processing
		return await analyzeImage(imageData: imageData, assetIdentifier: "memory_optimized")
	}
}

final class AnalysisStatsCollector: ObservableObject {
	@Published var totalAnalyzed = 0
	@Published var averageAnalysisTime: TimeInterval = 0
	@Published var memoryUsage: Int = 0

	func recordAnalysis(duration: TimeInterval) {
		totalAnalyzed += 1
		averageAnalysisTime =
			(averageAnalysisTime * Double(totalAnalyzed - 1) + duration) / Double(totalAnalyzed)
	}
}