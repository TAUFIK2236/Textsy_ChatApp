import SwiftUI

struct NotificationView: View {
    @State private var isDrawerOpen = false
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var session: UserSession
    @StateObject private var notificationVM = NotificationViewModel()
    @StateObject private var chatVM = ChatSessionViewModel()
    @State private var isProcessing: [String: Bool] = [:]


    var body: some View {
        VStack {
            // 🔝 Top Bar
            HStack(alignment: .center){
                Button {
                    isDrawerOpen.toggle()
                } label: {
                    Image(systemName: "line.3.horizontal")
                        .font(.title.bold())
                        .foregroundColor(.white)
                        .padding(10)
                }

                Spacer()

                Text("Notifications")
                    .foregroundColor(.white)
                    .font(.title.bold())

                Spacer()
                Spacer()
            }
            .padding(.horizontal)

            // 📩 ScrollView of Requests
            ScrollView {
                LazyVStack(spacing: 15) {
                    ForEach(notificationVM.notifications) { notif in
                        Button(action: {
                            appRouter.goToUserProfile(id: notif.senderId)
                        }) {
                            notificationCard(for: notif)
                        }
                    }
                }
                .padding()
            }
            .background(Color(.bgc))
        }
        .background(Color(.bgc))
        .onAppear {
            notificationVM.listenForNotifications(for: session.uid)

        }
        .overlay(
            SideDrawerView(
                isOpen: $isDrawerOpen,
                currentPage: appRouter.currentPage,
                goTo: { page in
                    withAnimation {
                        appRouter.currentPage = page
                        isDrawerOpen = false
                    }
                },
                onLogout: {
                    UserSession.shared.clear()
                    isDrawerOpen = false
                },
                onExit: { exit(0) }
            )
            .transition(.move(edge: .leading))
            .animation(.easeInOut, value: isDrawerOpen)
            .opacity(isDrawerOpen ? 1 : 0)
        )
    }

    // MARK: - Notification Card View
    private func notificationCard(for notif: NotificationModel) -> some View {
        HStack(spacing: 12) {
            profileImage(for: notif.senderImageUrl)
                .frame(width: 50, height: 50)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(notif.senderName)
                    .foregroundColor(.white)
                    .font(.body.bold())

                Text(notif.message)
                    .foregroundColor(.gray)
                    .font(.caption)

                Text(formatDate(notif.timestamp))
                    .foregroundColor(.gray)
                    .font(.caption2)
            }

            Spacer()

            // Show loading spinner
            if isProcessing[notif.id] == true {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(width: 20, height: 20)
            }

            // Show buttons ONLY for "request" type
            else if notif.type == .request {
                HStack(spacing: 6) {
                    Button("Say Hi") {
                        Task {
                            isProcessing[notif.id] = true
                            let chatId = generateChatId(session.uid, notif.senderId)
                            await notificationVM.sendHiMessage(
                                to: notif.senderId,
                                chatId: chatId,
                                userName: notif.senderName,
                                userImage: notif.senderImageUrl
                            )
                            await notificationVM.markAsResponded(notificationId: notif.id)
                            isProcessing[notif.id] = false
                        }
                    }
                    .font(.body.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green)
                    .cornerRadius(8)

                    Button("Decline") {
                        Task {
                            isProcessing[notif.id] = true
                            await notificationVM.deleteNotification(notificationId: notif.id)
                            isProcessing[notif.id] = false
                        }
                    }
                    .font(.body.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red)
                    .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.fieldT))
        .cornerRadius(12)
    }

    private func profileImage(for urlStr: String?) -> some View {
        if let urlStr = urlStr, let url = URL(string: urlStr), !urlStr.isEmpty {
            return AnyView(
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Image("profile").resizable().scaledToFill()
                }
            )
        } else {
            return AnyView(Image("profile").resizable().scaledToFill())
        }
    }

    // MARK: - Helpers
    private func generateChatId(_ uid1: String, _ uid2: String) -> String {
        return [uid1, uid2].sorted().joined(separator: "_")
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
