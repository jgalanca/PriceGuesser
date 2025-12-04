import OSLog

enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.priceguesser.app"

    static let game = Logger(subsystem: subsystem, category: "game")
    static let data = Logger(subsystem: subsystem, category: "data")
    static let ui = Logger(subsystem: subsystem, category: "ui")
    static let lifecycle = Logger(subsystem: subsystem, category: "lifecycle")
    static let error = Logger(subsystem: subsystem, category: "error")
}

extension Logger {
    func logError(
        _ message: String,
        error: Error,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        self.error("\(message): \(error.localizedDescription) [\(file):\(line) \(function)]")
    }

    func logDataOperation(
        _ operation: String,
        entity: String,
        success: Bool
    ) {
        if success {
            self.info("✅ \(operation) \(entity) - success")
        } else {
            self.error("❌ \(operation) \(entity) - failed")
        }
    }

    func logNavigation(from: String, to: String) {
        self.debug("Navigation: \(from) → \(to)")
    }

    func logUserAction(_ action: String, target: String) {
        self.info("User action: \(action) on \(target)")
    }
}
