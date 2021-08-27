//
//  BluetoothManager.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/08/2021.
//

import Foundation
import CoreBluetooth

// The Bluetooth Manager handles all searching for, creating connection to
// and sending/receiving messages to/from other Bluetooth devices.

class ChatBrain: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate {
    
        
    @Published var discoveredDevices: [Device] = []
    var connectedCharateristics: [CBCharacteristic] = []
    
    // Holds all messages received from all peripherals.
    @Published var conversations: [Conversation] = []
    
    var centralManager: CBCentralManager!
    var peripheralManager: CBPeripheralManager!

    var characteristic: CBMutableCharacteristic?
    
    var seenMessages: [Int] = []
    
    override init() {
        super.init()
        
        // Set up the central and peripheral manager objects to be used across the app.
        centralManager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        centralManager.delegate = self
    }
    
    
    /*
     Send a string to all connected devices.
     */
    func sendMessage(for receiver: String, text message: String) {
        
        guard message != "" else { return }
        
        if let characteristic = self.characteristic {
            
            let username = UserDefaults.standard.string(forKey: "Username")!
            
            let packet = Message(
                id: Int.random(in: 0...1000),
                sender: username,
                receiver: receiver,
                text: message
            )
            
            seenMessages.append(packet.id)
            
            do {
                let messageEncoded = try JSONEncoder().encode(packet)

                peripheralManager.updateValue(messageEncoded, for: characteristic, onSubscribedCentrals: nil)
            } catch {
                print("Error encoding message: \(message) -> \(error)")
            }
        }
    }
    
    
    /*
     Get the exchanged messages with a given user.
     Used when loading the ChatView()
     */
    func getConversation(sender author: String) -> [Message] {
        for conversation in conversations {
            if conversation.author == author {
                return conversation.messages
            }
        }
        print("There was an error fetching conversation from \(author)")
        return []
    }
    
    
    /*
     Add a sent message to the conversation. Used when sending a device a
     new message.
     */
    func addMessage(for receiver: String, text: String) {
        guard text != "" else { return } // Do not add empty messages.
        
        let username = UserDefaults.standard.string(forKey: "Username")!
        
        // Check which conversation to add the message to.
        for (index, conv) in conversations.enumerated() {
            if conv.author == receiver {
                
                let message = Message(
                    id: Int.random(in: 0...1000),
                    sender: username,
                    receiver: receiver,
                    text: text
                )
                
                conversations[index].addMessage(add: message)
            }
        }
    }
    
    /*
     Remove a device from discoveredDevices and drop connection to it.
     */
    func cleanUpPeripheral(_ peripheral: CBPeripheral) {
        
        for (index, device) in discoveredDevices.enumerated() {
            
            if device.peripheral == peripheral {
                
                centralManager.cancelPeripheralConnection(peripheral)
                
                discoveredDevices.remove(at: index)
                return
            }
        }
    }
}




