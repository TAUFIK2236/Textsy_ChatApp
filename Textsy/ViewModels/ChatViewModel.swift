//
//  ChatViewModel.swift
//  Textsy
//
//  Created by Anika Tabasum on 7/16/25.
//


// ViewModels/ChatViewModel.swift

import Foundation

class ChatViewModel: ObservableObject {
    @Published var chats: [ChatModel] = []

    init() {
        loadMockChats()
    }

    private func loadMockChats() {
        self.chats = [
            ChatModel(id: "1", userName: "Jane Williams", lastMessage: "Hi! How are you?", timeStamp: Date(), profileImageURL: "https://randomuser.me/api/portraits/women/1.jpg", unreadCount: 1),
            ChatModel(id: "2", userName: "Albert Johnson", lastMessage: "Are you coming today?", timeStamp: Date().addingTimeInterval(-3600), profileImageURL: "https://randomuser.me/api/portraits/men/2.jpg", unreadCount: 0),
            ChatModel(id: "3", userName: "Kathryn Murphy", lastMessage: "Sure, that sounds good!", timeStamp: Date().addingTimeInterval(-86400), profileImageURL: "https://randomuser.me/api/portraits/women/3.jpg", unreadCount: 2)
        ]
    }
}
