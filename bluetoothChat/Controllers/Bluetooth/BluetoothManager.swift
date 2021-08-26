//
//  BluetoothManager.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/08/2021.
//

import Foundation
import CoreBluetooth
import UserNotifications

// The Bluetooth Manager handles all searching for, creating connection to
// and sending/receiving messages to/from other Bluetooth devices.

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate {
    
    
    // Published variables are used outside of this class.
    @Published var isReady: Bool = false
    
    var discoveredPeripherals: [Device] = []
    var connectedCharateristics: [CBCharacteristic] = []
    
    // Holds all messages received from all peripherals.
    @Published var conversations: [Conversation] = []
    @Published var messages: [Message] = []
    
    let service = Service()
    
    var centralManager: CBCentralManager!
    var peripheralManager: CBPeripheralManager!

    var characteristic: CBMutableCharacteristic?
    
    override init() {
        super.init()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        centralManager.delegate = self
    }
    
    // MARK: Functions allowed to call from other classes.
    
    /*
     Send data to all connected peripherals encoded as a JSON data stream.
     It is then up to the receipent to decode the data.
     */
    func sendData(message: String) {
        
        guard message != "" else { return }
        
        if let characteristic = self.characteristic {
            
            let username = UserDefaults.standard.string(forKey: "Username")!
            let packet = Message(
                id: Int.random(in: 1...1000),
                text: message,
                // If no username has been saved in UserDefaults then use the name of the device.
                author: username
            )
            
            let encoder = JSONEncoder()
            
            do {
                let messageEncoded = try encoder.encode(packet)
                print("-")
                peripheralManager.updateValue(messageEncoded, for: characteristic, onSubscribedCentrals: nil)
            } catch {
                print("Error encoding message: \(message) -> \(error)")
            }
        }
    }
    
    
    /* Get a conversation with some user. Used for displaying the chat */
    func getConversation(author: String) -> [Message] {
        for conversation in conversations {
            if conversation.author == author {
                return conversation.messages
            }
        }
        print("There was an error fetching conversation from \(author)")
        return []
    }
    
    /* Add a message to a conversation - used when sending messages*/
    func addMessage(receipent: String, messageText: String) {
        for (index, conv) in conversations.enumerated() {
            if conv.author == receipent {
                let message = Message(
                    id: Int.random(in: 0...1000),
                    text: messageText,
                    author: UserDefaults.standard.string(forKey: "Username")!)
                conversations[index].addMessage(add: message)
            }
        }
    }
    
    
    // MARK: Helper functions.
    
    /*
     Add messages to the correct conversation or create a new one if the
     sender has not been seen before.
     */
    func retreiveData(_ message: Message) {
        var authorFound = false
        //  Loop trough conversations to find a match if possible.
        for (index, conv) in conversations.enumerated() {
            if conv.author == message.author {
                authorFound = true
                conversations[index].addMessage(add: message)
                conversations[index].updateLastMessage(new: message)
            }
        }
        //  Create a new conversation if the sender has not been seen.
        if !authorFound {
            conversations.append(
                Conversation(
                    id: message.id,
                    author: message.author,
                    lastMessage: message,
                    messages: [message]
                )
            )
        }
        
        /* Send a notification when we receive a message */
        let content = UNMutableNotificationContent()
        content.title = message.author
        content.body = message.text
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
    
    
    // MARK: TODO: Implement cleanup.
    func cleanUp(_ device: Device) {
//        discoveredPeripherals.removeAll() { device in
//            return device == peripheral
//        }
//
//        centralManager.cancelPeripheralConnection(peripheral)
//        print(centralManager.retrieveConnectedPeripherals(withServices: [self.service.UUID]))
//        print("Cleanup (on device: \(peripheral.name ?? "Unknown")")
    }
}





