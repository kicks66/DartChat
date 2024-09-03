import Foundation
import CoreData

class MessageStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func storeMessage(_ message: StoredMessage) {
        let entity = StoredMessageEntity(context: context)
        entity.id = message.id
        entity.messageData = try? JSONEncoder().encode(message.originalMessage)
        entity.createdAt = message.createdAt
        entity.attemptCount = Int32(message.attemptCount)
        
        do {
            try context.save()
        } catch {
            print("Failed to save StoredMessage: \(error)")
        }
    }
    
    func retrieveMessages() -> [StoredMessage] {
        let fetchRequest: NSFetchRequest<StoredMessageEntity> = StoredMessageEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \StoredMessageEntity.createdAt, ascending: true)]
        
        do {
            let entities = try context.fetch(fetchRequest)
            return entities.compactMap { entity in
                guard let id = entity.id,
                      let messageData = entity.messageData,
                      let createdAt = entity.createdAt,
                      let originalMessage = try? JSONDecoder().decode(Message.self, from: messageData) else {
                    return nil
                }
                
                var storedMessage = StoredMessage(originalMessage: originalMessage)
                storedMessage.id = id
                storedMessage.createdAt = createdAt
                storedMessage.attemptCount = Int(entity.attemptCount)
                return storedMessage
            }
        } catch {
            print("Failed to retrieve StoredMessages: \(error)")
            return []
        }
    }
    
    func deleteMessage(_ message: StoredMessage) {
        let fetchRequest: NSFetchRequest<StoredMessageEntity> = StoredMessageEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", message.id as CVarArg)
        
        do {
            let entities = try context.fetch(fetchRequest)
            entities.forEach { context.delete($0) }
            try context.save()
        } catch {
            print("Failed to delete StoredMessage: \(error)")
        }
    }
    
    func updateAttemptCount(for message: StoredMessage) {
        let fetchRequest: NSFetchRequest<StoredMessageEntity> = StoredMessageEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", message.id as CVarArg)
        
        do {
            let entities = try context.fetch(fetchRequest)
            guard let entity = entities.first else { return }
            
            entity.attemptCount += 1
            try context.save()
        } catch {
            print("Failed to update attempt count: \(error)")
        }
    }

    func isMessageStored(withId id: Int32) -> Bool {
        let fetchRequest: NSFetchRequest<StoredMessageEntity> = StoredMessageEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        fetchRequest.fetchLimit = 1
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Failed to check if message is stored: \(error)")
            return false
        }
    }
}