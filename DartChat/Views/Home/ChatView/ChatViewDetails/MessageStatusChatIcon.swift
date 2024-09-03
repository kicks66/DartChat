//
//  MessageStatus.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/09/2021.
//

import SwiftUI

/// Status of a message as seen in the ``ChatView``
struct MessageStatusChatIcon: View {
    let status: MessageStatus
    
    var body: some View {
        switch status {
        case .sent:
            Image("single-grey")
                .resizable()
                .frame(width: 9, height: 9)
        case .delivered:
            Image("double-grey")
                .resizable()
                .frame(width: 16, height: 9)
        case .read:
            Image("double-yellow")
                .resizable()
                .frame(width: 16, height: 9)
        case .stored:
            Image(systemName: "clock")
                .resizable()
                .frame(width: 16, height: 16)
        case .expired:
            Image(systemName: "exclamationmark.triangle")
                .resizable()
                .frame(width: 16, height: 16)
        case .failed:
            Image(systemName: "wifi.slash")
                .resizable()
                .frame(width: 16, height: 16)
        default:
            Image(systemName: "exclamationmark.bubble.fill")
                .resizable()
                .frame(width: 16, height: 16)
        }
    }
}
