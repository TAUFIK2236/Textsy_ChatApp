import SwiftUI
import Foundation
import FirebaseFirestore


struct ChatView: View {
    @Environment(\.dismiss) var dismiss
    @State private var messageText = ""
    @State private var chatTitle = ""
    @StateObject private var viewModel = ChatViewModel()
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var session : UserSession
    let chatId: String
    
    @State private var  lastMessageId :String?

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

                    Image("profile")
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
                ScrollViewReader{ proxy in
                ScrollView {
                    LazyVStack(spacing: 10) {
                        
                        
                        // ⬆️ Load more button at the very top
                        if viewModel.hasMoreOlder {
                            Button {
                                Task {
                                    // Remember current first visible id to keep position stable (optional)
                                    let firstIdBefore = viewModel.messages.first?.id
                                    await viewModel.loadOlder(chatId: chatId)

                                    // After prepending, keep the old first message near top (nice UX)
                                    if let anchorId = firstIdBefore {
                                        withAnimation(.easeInOut) {
                                            proxy.scrollTo(anchorId, anchor: .top)
                                        }
                                    }
                                }
                            } label: {
                                Text(viewModel.isloadingMore ? "Loading..." : "Load more")
                                    .font(.footnote.bold())
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding(.vertical, 6)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 8)
                        }
                        
                        
                        ForEach(viewModel.messages) { msg in
                            ChatBubble(
                                message: ChatBubbleModel(
                                    text: msg.text,
                                    isMe: msg.senderId == session.uid,
                                    time: formatDate(msg.timestamp)
                                )
                            )
                            .id(msg.id)
                        }
                        // Invisible anchor at the bottom for smooth scroll
                      //  Color.clear.frame(height: 1).id("BOTTOM")
                    }
                    .padding(.horizontal,3)
                    .padding(.top, 10)
                }
                .background(Color(.bgc))
                // 🔁 Auto-scroll when messages change (new send/receive)
                .onChange(of: viewModel.messages.count, initial: false) { _, _ in
                    // scroll to the last message (BOTTOM anchor)
                    withAnimation(.easeInOut) {
                        proxy.scrollTo("BOTTOM", anchor: .bottom)
                    }
                }
                // Also remember last message id for potential fine control (optional)
                .onChange(of: viewModel.messages.last?.id, initial: false) { _, newVal in
                    lastMessageId = newVal
                }
            }
                    
                    
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
                           // viewModel.listenToMessages(chatId: chatId)
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
                    viewModel.listenToMessages(chatId: chatId)
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
                .padding(.horizontal, 5)
            }
            .frame(maxWidth: .infinity, alignment: message.isMe ? .trailing : .leading)

            if !message.isMe { Spacer() }
        }
        .padding(.horizontal, 5)
    }
}


