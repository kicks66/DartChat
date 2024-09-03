import Foundation

struct StoredMessage: Codable, Identifiable {
    let id: UUID
    let originalMessage: Message
    let createdAt: Date
    var attemptCount: Int
    
    init(originalMessage: Message) {
        self.id = UUID()
        self.originalMessage = originalMessage
        self.createdAt = Date()
        self.attemptCount = 0
    }
    
    var isExpired: Bool {
        return attemptCount >= 10 || Date().timeIntervalSince(createdAt) > 600 // 10 minutes
    }
}