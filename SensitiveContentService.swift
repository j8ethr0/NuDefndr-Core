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