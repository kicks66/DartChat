//
//  SettingsView.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 25/08/2021.
//

import SwiftUI

/// The `READ` setting toggle which is a setting that
/// can be turned on and off based on user preferences.
///
/// If it is enabled then the sender of messages can see that you have
/// read their messages.
///
/// - Note: Default value is off.
struct ReadToggle: View {
    
    /// The read status toggle as a boolean saved to `UserDefaults`
    @State var readStatusToggle: Bool = UserDefaults.standard.bool(forKey: "settings.readmessages")
    
    var body: some View {
        VStack {
            Toggle("Read receipts", isOn: $readStatusToggle).onChange(of: readStatusToggle, perform: { value in
                UserDefaults.standard.setValue(readStatusToggle, forKey: "settings.readmessages")
            }).toggleStyle(SwitchToggleStyle(tint: .accentColor))
        }
    }
}

/// The main `SettingsView` which shows a number of subviews for different purposes.
///
/// It is here that we set new usernames and toggles different settings.
/// It also shows contact information for dIM among other things.
struct SettingsView: View {
    /// CoreDate context object
    @Environment(\.managedObjectContext) var context
    @Environment(\.colorScheme) var colorScheme
    
    /// The `UserDefaults` for getting information from persistent storage.
    private let defaults = UserDefaults.standard
    
    /// The `ChatBrain` to get things from the logic layer.
    @EnvironmentObject var chatHandler: ChatHandler
    
    @State private var usernameTextFieldText = ""
    @State private var usernameTextFieldIdentifier = ""
    
    @State private var invalidUsernameAlertMessageIsShown = false
    @State private var invalidUsernameAlertMessage = ""
    
    @State private var changeUsernameAlertMessageIsShown = false
    
    private let usernameValidator = UsernameValidator()
    
    /// UserDefaults value of `settings.readmessages`. Default value is `true`.
    @AppStorage("settings.readmessages") var readStatusToggle = true
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 65)
                    
                    TextField("Choose a username...", text: $usernameTextFieldText, onCommit: {
                        UIApplication.shared.endEditing()
                        
                        switch usernameValidator.validate(username: usernameTextFieldText) {
                        case .valid, .demoMode:
                            changeUsernameAlertMessageIsShown = true
                        case .error(message: let errorMessage):
                            invalidUsernameAlertMessage = errorMessage
                            invalidUsernameAlertMessageIsShown = true
                        default: ()
                        }
                    })
                    .keyboardType(.namePhonePad)
                    .padding()
                    .cornerRadius(10.0)
                    
                    Text("# " + usernameTextFieldIdentifier)
                        .foregroundColor(.gray)
                    
                    Spacer()
                }
                .foregroundColor(.accentColor)
            } header: {
                Text("My Username")
            } footer: {
                Text("If you change your username, you and your contacts will have to add each other again.")
            }
            
            Section {
                Toggle(isOn: $readStatusToggle) {
                    Label("Show Read Receipts", systemImage: "eye.fill")
                        .imageScale(.large)
                }
            } footer: {
                Text("Read receips allow your contacts to see if you have read their messages.")
            }
            
            Section {
                NavigationLink(destination: AboutView()) {
                    Label("About & Contact", systemImage: "questionmark")
                        .foregroundColor(.accentColor)
                        .imageScale(.large)
                }
            }
            
            Section {
                Label(chatHandler.discoveredDevices.count < 0 ? "No devices connected." : "\(chatHandler.discoveredDevices.count) devices connected.", systemImage: "ipad.and.iphone")
                    .imageScale(.large)
                
                Label("\(chatHandler.routedCounter) messages routed in this session.", systemImage: "arrow.left.arrow.right")
                    .imageScale(.large)
            } header: {
                Text("Connectivity")
            } footer: {
                Text("Information about connected devices and amount of messages routed through your phone.")
            }
        }
        .symbolRenderingMode(.hierarchical)
        .autocapitalization(.none)
        .disableAutocorrection(true)
        .navigationBarTitle("Settings", displayMode: .large)
        .onAppear {
            setUsernameTextFieldToStoredValue()
        }
        // MARK: Alerts
        // Invalid username alert
        .alert("Invalid username", isPresented: $invalidUsernameAlertMessageIsShown) {
            Button("OK", role: .cancel) {
                setUsernameTextFieldToStoredValue()
            }
        } message: {
            Text(invalidUsernameAlertMessage)
        }
        // Change username alert
        .alert("Change username", isPresented: $changeUsernameAlertMessageIsShown) {
            Button("OK") {
                let state = usernameValidator.set(username: usernameTextFieldText, context: context)
                switch state {
                case .valid(let userInfo), .demoMode(let userInfo):
                    usernameTextFieldText = userInfo.name
                    usernameTextFieldIdentifier = userInfo.id
                    CryptoHandler.resetKeys()
                default:
                    setUsernameTextFieldToStoredValue()
                }
            }
            Button("Cancel", role: .cancel) {
                setUsernameTextFieldToStoredValue()
            }
        } message: {
            Text("By changing your username you cannot send or receive messages from your current contacts. You will have to add each other again.")
        }
    }
    
    private func setUsernameTextFieldToStoredValue() {
        usernameTextFieldText = usernameValidator.userInfo?.name ?? ""
        usernameTextFieldIdentifier = usernameValidator.userInfo?.id ?? ""
    }
}
