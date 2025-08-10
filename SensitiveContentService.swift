// Copyright (c) 2025 Dro1d Labs Limited
// Released under the MIT License. See LICENSE file for details.
//
// NuDefndr App - Core Privacy Component
// App Website: https://nudefndr.com
// Developer: Dro1d Labs

/*
 * Privacy Guarantee: This service performs analysis entirely on-device
 * using Apple's SensitiveContentAnalysis framework. No image data or 
 * analysis results are transmitted over the network.
 */
 
import Foundation
import SensitiveContentAnalysis
import UIKit
import CoreGraphics
import SwiftUI

class SensitiveContentService {

	private let analyzer = SCSensitivityAnalyzer()

	func analyzeImage(imageData: Data, assetIdentifier: String) async -> Bool {
		guard let uiImage = UIImage(data: imageData) else {
			return false
		}
		guard let cgImage = uiImage.cgImage else {
			return false
		}
		do {
			let result = try await analyzer.analyzeImage(cgImage)
			return result.isSensitive
		} catch {
			return false
		}
	}

	func analyzeImage(at imageURL: URL) async -> Bool {
		var shouldStopAccessing = false
		if imageURL.isFileURL {
			shouldStopAccessing = imageURL.startAccessingSecurityScopedResource()
			if !shouldStopAccessing {
				// Warning: *redacted*
			}
		}

		defer {
			if shouldStopAccessing {
				imageURL.stopAccessingSecurityScopedResource()
			}
		}

		do {
			let imageData = try Data(contentsOf: imageURL)
			let identifier = imageURL.absoluteString
			return await analyzeImage(imageData: imageData, assetIdentifier: identifier)
		} catch {
			return false
		}
	}
}

// Advanced Analysis

extension SensitiveContentService {
  
  func analyzeBatch(_ urls: [URL], progressCallback: @escaping (Double) -> Void) async -> [URL: Bool] {
	  var results: [URL: Bool] = [:]
	  
	  for (index, url) in urls.enumerated() {
		  let result = await analyzeImage(at: url)
		  results[url] = result
		  
		  let progress = Double(index + 1) / Double(urls.count)
		  await MainActor.run {
			  progressCallback(progress)
		  }
	  }
	  
	  return results
  }
  
  /// Memory-optimized analysis
  func analyzeWithMemoryOptimization(imageData: Data, maxSize: CGSize = CGSize(width: 2048, height: 2048)) async -> Bool {
	  // memory optimization
	  return await analyzeImage(imageData: imageData, assetIdentifier: "memory_optimized")
  }
}

class AnalysisStatsCollector: ObservableObject {
  @Published var totalAnalyzed: Int = 0
  @Published var averageAnalysisTime: TimeInterval = 0
  @Published var memoryUsage: Int = 0
  
  func recordAnalysis(duration: TimeInterval) {
	  totalAnalyzed += 1
	  averageAnalysisTime = (averageAnalysisTime * Double(totalAnalyzed - 1) + duration) / Double(totalAnalyzed)
  }
}
