import SwiftUI
import Firebase

struct NotificationView: View {
    @State private var isDrawerOpen = false
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var session: UserSession
    @StateObject var requestVM = RequestViewModel()
    let chatVM = ChatSessionViewModel()

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                // 🔝 Top bar
                HStack {
                    Button {
                        isDrawerOpen.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.title.bold())
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.white.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    Spacer()

                    Text("Notifications")
                        .font(.title.bold())
                        .foregroundColor(.white)

                    Spacer()
                    Spacer().frame(width: 44)
                }
                .padding(.horizontal)

                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(requestVM.incomingRequests) { request in
                            HStack(spacing: 12) {
                                profileImage(for: request)
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    .onTapGesture {
                                        appRouter.currentPage = .userProfile(userId: request.senderId)
                                    }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(request.name)
                                        .foregroundColor(.white)
                                        .font(.body.bold())

                                    Text("requested to chat.")
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                }

                                Spacer()

                                Button("Say Hi") {
                                    Task {
                                        await sayHi(to: request)
                                    }
                                }
                                .font(.body.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.blue)
                                .cornerRadius(10)

                                Button("Decline") {
                                    Task {
                                        await decline(request: request)
                                    }
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.red)
                                .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                            .background(Color(.fieldT))
                            .cornerRadius(16)
                        }
                    }
                    .padding()
                }
            }
            .padding(.top)
            .background(Color(.bgc))
            .blur(radius: isDrawerOpen ? 8 : 0)
            .onAppear {
                requestVM.listenForIncomingRequests(for: session.uid)
            }

            // Drawer
            if isDrawerOpen {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isDrawerOpen = false
                        }
                    }

                SideDrawerView(
                    isOpen: $isDrawerOpen,
                    currentPage: .notifications,
                    goTo: { page in
                        withAnimation {
                            appRouter.currentPage = page
                            isDrawerOpen = false
                        }
                    },
                    onLogout: {
                        session.clear()
                        isDrawerOpen = false
                    },
                    onExit: {
                        exit(0)
                    }
                )
                .transition(.move(edge: .leading))
            }
        }
    }

    // MARK: - Say Hi Logic
    func sayHi(to request: RequestModel) async {
        let myId = session.uid
        let otherId = request.senderId
        let chatId = [myId, otherId].sorted().joined(separator: "_")

        // 1. Accept request
        await requestVM.acceptRequest(currentUserId: myId, from: otherId)

        // 2. Create chat
        await chatVM.createChatIfNotExists(
            chatId: chatId,
            user1Id: myId,
            user2Id: otherId,
            user2Name: request.name,
            user2Image: request.profileImageUrl ?? ""
        )

        // 3. Send "Hi" message
        await chatVM.sendMessage(chatId: chatId, text: "Hi, how are you?")
    }

    func decline(request: RequestModel) async {
        await requestVM.declineRequest(currentUserId: session.uid, from: request.senderId)
    }

    // MARK: - Async image with fallback
    private func profileImage(for request: RequestModel) -> some View {
        if let urlStr = request.profileImageUrl,
           !urlStr.trimmingCharacters(in: .whitespaces).isEmpty,
           let url = URL(string: urlStr) {
            return AnyView(
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Image("Profile").resizable().scaledToFill()
                }
            )
        } else {
            return AnyView(
                Image("profile")
                    .resizable()
                    .scaledToFill()
            )
        }
    }
}

// MARK: - Preview
#Preview("Notification View – Live") {
    NotificationView()
        .environmentObject(UserSession.shared)
        .environmentObject(AppRouter())
        .preferredColorScheme(.dark)
}
