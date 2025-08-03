////
////  ChatView.swift
////  Textsy
////
////  Created by Anika Tabasum on 7/18/25.
////
//
//
//import SwiftUI
//import Foundation
//
//struct ChatView: View {
//    @State private var messageText = ""
//   // @State private var chatId: String? = nil
//
//    @StateObject private var viewModel = ChatSessionViewModel()
//    @EnvironmentObject var session : UserSession
//    let chatId: String
//    
//
//    var body: some View {
//        GeometryReader { geometry in
//            VStack(spacing: 0) {
//
//
//                // Custom Top Bar
//                HStack {
//                    Button(action: {
//                        // Back action
//                    }) {
//                        Image(systemName: "chevron.left")
//                            .font(.title2.bold())
//                            .foregroundColor(.white)
//                    }
//
//                    Image("Logo1") // Your asset name
//                        .resizable()
//                        .frame(width: 40, height: 40)
//                        .clipShape(Circle())
//
//                    VStack(alignment: .leading, spacing: 2) {
//                        Text("")
//                            .foregroundColor(.white)
//                            .font(.headline.bold())
//
//                        Text("online")
//                            .foregroundColor(.gray)
//                            .font(.caption)
//                    }
//
//                    Spacer()
//
//                    HStack(spacing: 20) {
//                        Image(systemName: "video.fill")
//                        Image(systemName: "phone.fill")
//                        Image(systemName: "ellipsis")
//                    }
//                    .foregroundColor(.white)
//                }
//                .padding(.bottom)
//                .padding(.horizontal,10)
//                .background(Color(.appbar))
//
//                // Messages
//                ScrollView {
//                    LazyVStack(spacing: 10) {
//                        ForEach(viewModel.messages) { msg in
//                            ChatBubble(message: ChatBubbleModel(text: msg.text, isMe: msg.senderId == session.uid, time: formatDate(msg.timestamp)
//                                
//                            ))
//                        }
//                    }
//                    .padding(.horizontal)
//                    .padding(.top, 10)
//                }
//                .background(Color(.bgc))
//
//                // Input field
//                HStack(spacing: 12) {
//                    TextField("Message", text: $messageText)
//                        .padding(10)
//                        .background(Color(.gray))
//                        .cornerRadius(25)
//                        .foregroundColor(.white)
//
//                    Button(action: {
//                        // TODO: Send message
//                    }) {
//                        Image(systemName: "photo")
//                            .padding(10)
//                            .background(Color.green)
//                            .clipShape(Circle())
//                            .foregroundColor(.white)
//                    }
//                    Button(action: {
//                        Task {
//                            await viewModel.sendMessage(chatId: chatId ?? "", text: messageText)
//                            messageText = "" // clear field
//                            await viewModel.fetchMessages(chatId: chatId) // reload messages
//                        }
//                        // TODO: Send message
//                    }) {
//                        Image(systemName: "paperplane.fill")
//                            .padding(10)
//                            .background(Color.green)
//                            .clipShape(Circle())
//                            .foregroundColor(.white)
//                    }
//                    
//                }
//                
//                .padding(.horizontal)
//                .padding(.vertical, 10)
//                .background(Color(.bgc))
//                .onAppear {
//                    Task {
//                        await viewModel.fetchMessages(chatId: chatId)
//                    }
//                }
//                
//            }
//        }
//    }
//    
//    
//    private func formatDate(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.timeStyle = .short
//        return formatter.string(from: date)
//    }
//
//}
//
//
//#Preview("ChatView - Dark Mode") {
//    ChatView(chatId: "sampleUser123")
//        .environmentObject(UserSession.shared)
//        .preferredColorScheme(.dark)
//}
//
//
//
//
//import Foundation
//
//struct ChatBubbleModel: Identifiable {
//    let id = UUID()
//    let text: String
//    let isMe: Bool
//    let time: String
//}
//
////let sampleMessages: [ChatBubbleModel] = [
////    .init(text: "Got job", isMe: false, time: "3:31 PM"),
////    .init(text: "❤️", isMe: false, time: "3:31 PM"),
////    .init(text: "Josffffffffffs  gggggg ggggggggggggggg hhhhhhhhhhhhh", isMe: true, time: "3:32 PM"),
////    .init(text: "Perfect", isMe: true, time: "3:45 PM"),
////    .init(text: "Apply kor", isMe: false, time: "5:01 PM"),
////]
//
//
//
//import SwiftUI
//
//struct ChatBubble: View {
//    let message: ChatBubbleModel
//
//    var body: some View {
//        HStack (alignment:message.isMe ? .lastTextBaseline : .firstTextBaseline ){
//            if message.isMe { Spacer() }
//
//            VStack(alignment: message.isMe ? .trailing: .leading, spacing: 4) {
//                Text(message.text)
//                    .foregroundColor(.white)
//                    .padding()
//                    .background(message.isMe ? Color.appbar : Color.gray.opacity(0.3))
//                    .cornerRadius(15)
//
//                HStack(spacing: 4) {
//                    Text(message.time)
//                        .font(.caption2)
//                        .foregroundColor(.white.opacity(0.5))
//
//                    if message.isMe {
//                        Image(systemName: "checkmark.double")
//                            .resizable()
//                            .frame(width: 12, height: 10)
//                            .foregroundColor(.blue)
//                    }
//                }
//                .padding(.horizontal, 8)
//            }
//            .frame(maxWidth: .infinity, alignment: message.isMe ? .trailing : .leading)
//
//            if !message.isMe { Spacer() }
//        }
//        .padding(.horizontal, 10)
//    }
//}
//
import SwiftUI
import Foundation
import FirebaseFirestore


struct ChatView: View {
    @Environment(\.dismiss) var dismiss
    @State private var messageText = ""
    @State private var chatTitle = ""
    @StateObject private var viewModel = ChatSessionViewModel()
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var session : UserSession
    let chatId: String

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {

                // Custom Top Bar
                HStack {
                    Button(action: {
                        withAnimation {
                            appRouter.currentPage = .home // or .notification
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                    }

                    Image("Logo1")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        Text(chatTitle)
                            .foregroundColor(.white)
                            .font(.headline.bold())

                        Text("online")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }

                    Spacer()

                    HStack(spacing: 20) {
                        Image(systemName: "video.fill")
                        Image(systemName: "phone.fill")
                        Image(systemName: "ellipsis")
                    }
                    .foregroundColor(.white)
                }
                .padding(.bottom)
                .padding(.horizontal,10)
                .background(Color(.appbar))

                // Messages
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(viewModel.messages) { msg in
                            ChatBubble(message: ChatBubbleModel(text: msg.text, isMe: msg.senderId == session.uid, time: formatDate(msg.timestamp)))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
                .background(Color(.bgc))

                // Input field
                HStack(spacing: 12) {
                    TextField("Message", text: $messageText)
                        .padding(10)
                        .background(Color(.gray))
                        .cornerRadius(25)
                        .foregroundColor(.white)

                    Button(action: {
                        // TODO: Send image
                    }) {
                        Image(systemName: "photo")
                            .padding(10)
                            .background(Color.green)
                            .clipShape(Circle())
                            .foregroundColor(.white)
                    }
                    Button(action: {
                        Task {
                            await viewModel.sendMessage(chatId: chatId, text: messageText)
                            messageText = ""
                            await viewModel.fetchMessages(chatId: chatId)
                        }
                    }) {
                        Image(systemName: "paperplane.fill")
                            .padding(10)
                            .background(Color.green)
                            .clipShape(Circle())
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Color(.bgc))
            }
            .onAppear {
                Task {
                    await viewModel.fetchMessages(chatId: chatId)
                    let chatDoc = try? await Firestore.firestore().collection("chats").document(chatId).getDocument()
                    if let data = chatDoc?.data(),
                       let senderName = data["senderName"] as? String,
                       let receiverName = data["receiverName"] as? String {
                        self.chatTitle = (senderName == session.name) ? receiverName : senderName
                    }
                }
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct ChatBubbleModel: Identifiable {
    let id = UUID()
    let text: String
    let isMe: Bool
    let time: String
}

struct ChatBubble: View {
    let message: ChatBubbleModel

    var body: some View {
        HStack (alignment:message.isMe ? .lastTextBaseline : .firstTextBaseline ){
            if message.isMe { Spacer() }

            VStack(alignment: message.isMe ? .trailing: .leading, spacing: 4) {
                Text(message.text)
                    .foregroundColor(.white)
                    .padding()
                    .background(message.isMe ? Color.appbar : Color.gray.opacity(0.3))
                    .cornerRadius(15)

                HStack(spacing: 4) {
                    Text(message.time)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.5))

                    if message.isMe {
                        Image(systemName: "checkmark.double")
                            .resizable()
                            .frame(width: 12, height: 10)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 8)
            }
            .frame(maxWidth: .infinity, alignment: message.isMe ? .trailing : .leading)

            if !message.isMe { Spacer() }
        }
        .padding(.horizontal, 10)
    }
}
