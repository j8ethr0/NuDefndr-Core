# NuDefndr - Core Privacy Components

This repository contains selected open-source components from the NuDefndr iOS app, focusing on the core privacy and analysis functions.

**NuDefndr App:** https://dro1d.org/nuDefndr.html

## Purpose of This Repository

The primary goal of open-sourcing these components is **transparency**. We want users, researchers, and privacy advocates to be able to verify our core privacy claims:

* Sensitive content analysis is performed **entirely on the user's device** using Apple's native `SensitiveContentAnalysis` framework.
* Image data is **not transmitted** off the device for analysis by NuDefndr.

## Included Files

* **`SensitiveContentService.swift`**: This class encapsulates the interaction with Apple's `SensitiveContentAnalysis` framework, showing how image data (converted to `CGImage`) is passed to the on-device analyzer.
* **`ScanRangeOption.swift`**: A simple enum defining the date range options used for scanning within the app.

*(Note: This repository does not contain the full application source code, including UI, photo library interaction logic, incremental scanning logic, or other features.)*

## License

The code in this repository is released under the **MIT License**. See the [LICENSE](LICENSE) file for details.

## Disclaimer

This code is provided for transparency purposes. It represents core components but is not the complete, buildable application.
