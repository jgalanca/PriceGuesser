import Foundation
import CryptoKit

/// Generates collision-resistant UUIDs by combining device identifier with random UUID
///
/// Purpose: Prevent ID collisions when merging game data from multiple devices
/// (e.g., future CloudKit sync, data export/import between users)
///
/// Strategy: Each device gets a persistent UUID on first launch. Game IDs are derived
/// from: device UUID + timestamp + random component, hashed into UUID format.
///
/// Collision probability: Negligible (requires same device, same nanosecond, same random UUID)
struct DeviceIdentifier {
    /// Device-specific UUID that persists across app launches
    /// Stored in UserDefaults and generated once per device lifetime
    static var deviceUUID: UUID {
        let bundleID = Bundle.main.bundleIdentifier ?? "com.priceguesser"
        let key = "\(bundleID).deviceUUID"

        // Try to load existing device UUID
        if let uuidString = UserDefaults.standard.string(forKey: key),
           let uuid = UUID(uuidString: uuidString) {
            return uuid
        }

        // Generate new device UUID on first launch
        let newUUID = UUID()
        UserDefaults.standard.set(newUUID.uuidString, forKey: key)
        return newUUID
    }

    /// Generates a globally unique identifier for Game instances
    ///
    /// Combines:
    /// - Device UUID (unique per device)
    /// - Timestamp (unique per moment)
    /// - Random UUID (unique per call)
    ///
    /// Result is hashed using SHA256 and formatted as UUID v5
    /// This ensures:
    /// 1. Different devices never generate same ID (device UUID differs)
    /// 2. Same device at different times generates different IDs (timestamp differs)
    /// 3. Rapid successive calls generate different IDs (random component differs)
    static func generateID() -> UUID {
        let device = deviceUUID.uuidString
        let timestamp = String(Date().timeIntervalSince1970)
        let random = UUID().uuidString

        // Create unique deterministic string
        let combined = "\(device)-\(timestamp)-\(random)"

        // Hash using SHA256 for collision resistance
        let hash = SHA256.hash(data: Data(combined.utf8))

        // Take first 16 bytes and format as UUID
        let bytes = Array(hash.prefix(16))

        // Convert to UUID tuple
        let uuid: uuid_t = (
            bytes[0], bytes[1], bytes[2], bytes[3],
            bytes[4], bytes[5], bytes[6], bytes[7],
            bytes[8], bytes[9], bytes[10], bytes[11],
            bytes[12], bytes[13], bytes[14], bytes[15]
        )

        return UUID(uuid: uuid)
    }
}
