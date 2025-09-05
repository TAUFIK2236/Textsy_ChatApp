import SwiftUI
import FirebaseFirestore

struct ChatView: View {
    @Environment(\.dismiss) var dismiss
    @State private var messageText = ""
    @State private var chatTitle = ""
    @StateObject private var viewModel = ChatViewModel()
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var session: UserSession
    let chatId: String

    @State private var showNewMessageButton = false
    @State private var hasScrolledToBottomOnce = false

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // 🔝 Top Bar
                ChatTopBar(chatTitle: chatTitle) {
                    withAnimation {
                        appRouter.currentPage = .home
                    }
                }

                // 💬 Messages
                ScrollViewReader { proxy in
                    ZStack(alignment: .bottomTrailing) {
                        ScrollView {
                            LazyVStack(spacing: 10) {
                                ForEach(viewModel.messages, id: \.id) { msg in
                                    MessageRow(
                                        msg: msg,
                                        isMe: msg.senderId == session.uid,
                                        time: formatDate(msg.timestamp),
                                        chatId: chatId,
                                        viewModel: viewModel,
                                        loadOlderEnabled: hasScrolledToBottomOnce
                                    )
                                }

                                // 👇 Anchor for scroll-to-bottom
                                Color.clear.frame(height: 1).id("BOTTOM")
                            }
                            .padding(.horizontal, 3)
                            .padding(.top, 10)
                            .background(Color(.bgc))
                            .background(
                                GeometryReader { geo -> Color in
                                    DispatchQueue.main.async {
                                        let offset = geo.frame(in: .named("scroll")).maxY
                                        let screenHeight = UIScreen.main.bounds.height
                                        showNewMessageButton = offset > screenHeight * 0.9
                                    }
                                    return Color.clear
                                }
                            )
                        }
                        .coordinateSpace(name: "scroll")

                        // 🔄 Auto scroll when new message added
                        .onChange(of: viewModel.messages.last?.id, initial: false) { _, _ in
                            withAnimation {
                                proxy.scrollTo("BOTTOM", anchor: .bottom)
                            }
                        }

                        // 🔘 Floating Jump-to-Bottom Button
                        if showNewMessageButton {
                            Button {
                                proxy.scrollTo("BOTTOM", anchor: .bottom)
                            } label: {
                                Image(systemName: "chevron.down.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.green)
                                    .shadow(radius: 3)
                            }
                            .padding()
                        }
                    }
                    // ✅ Scroll to bottom once on appear
                    .onAppear {
                        Task {
                            viewModel.listenToMessages(chatId: chatId)

                            try? await Task.sleep(nanoseconds: 400_000_000)
                            withAnimation {
                                proxy.scrollTo("BOTTOM", anchor: .bottom)
                            }

                            hasScrolledToBottomOnce = true

                            let chatDoc = try? await Firestore.firestore()
                                .collection("chats")
                                .document(chatId)
                                .getDocument()
                            if let data = chatDoc?.data(),
                               let senderName = data["senderName"] as? String,
                               let receiverName = data["receiverName"] as? String {
                                self.chatTitle = (senderName == session.name) ? receiverName : senderName
                            }
                        }
                    }
                }

                // 📝 Input Bar
                HStack(spacing: 12) {
                    TextField("Message", text: $messageText)
                        .padding(10)
                        .background(Color(.gray))
                        .cornerRadius(25)
                        .foregroundColor(.white)

                    Button {
                        // future: send image
                    } label: {
                        Image(systemName: "photo")
                            .padding(10)
                            .background(Color.green)
                            .clipShape(Circle())
                            .foregroundColor(.white)
                    }

                    Button {
                        Task {
                            await viewModel.sendMessage(chatId: chatId, text: messageText)
                            messageText = ""
                        }
                    } label: {
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
        }
    }
}

// ✅ Chat top bar
private struct ChatTopBar: View {
    let chatTitle: String
    let backAction: () -> Void

    var body: some View {
        HStack {
            Button(action: backAction) {
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
        .padding(.horizontal, 10)
        .background(Color(.appbar))
    }
}

// ✅ Message row with smart load logic
private struct MessageRow: View {
    let msg: MessageModel
    let isMe: Bool
    let time: String
    let chatId: String
    let viewModel: ChatViewModel
    let loadOlderEnabled: Bool

    var body: some View {
        ChatBubble(message: ChatBubbleModel(
            text: msg.text,
            isMe: isMe,
            time: time
        ))
        .id(msg.id)
        .onAppear {
            if loadOlderEnabled,
               msg.id == viewModel.messages.first?.id,
               viewModel.hasMoreOlder,
               !viewModel.isloadingMore {
                Task { await viewModel.loadOlder(chatId: chatId) }
            }
        }
    }
}

// 💬 Chat bubble UI
struct ChatBubbleModel: Identifiable {
    let id = UUID()
    let text: String
    let isMe: Bool
    let time: String
}

struct ChatBubble: View {
    let message: ChatBubbleModel

    var body: some View {
        HStack(alignment: message.isMe ? .lastTextBaseline : .firstTextBaseline) {
            if message.isMe { Spacer() }

            VStack(alignment: message.isMe ? .trailing : .leading, spacing: 4) {
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
