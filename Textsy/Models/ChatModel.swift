
import Foundation

struct ChatModel: Identifiable {
    let id: String
    let userName: String
    let lastMessage: String
    let timeStamp: Date
    let profileImageURL: String
    let unreadCount: Int
}
