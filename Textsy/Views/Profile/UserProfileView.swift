import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject var session: UserSession
    @EnvironmentObject var appRouter: AppRouter
    @StateObject private var requestVM = RequestViewModel()


 
    
    let user: UserModel

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Custom Top Bar
                    HStack {
                        Button(action: {
                            if user.id == session.uid {
                                appRouter.goToHome() // 👈 back to Home if it's my own profile
                            } else {
                                appRouter.goToExplore()
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                        }


                        Spacer()

                        Text("Profile")
                            .font(.title3.bold())
                            .foregroundColor(.white)

                        Spacer()

                        Button(action: {
                            Task {
                                await requestVM.checkStatus(currentUserId: session.uid, viewedUserId: user.id)
                            }
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    if requestVM.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                            .padding()
                    }

                    
                    // MARK: - Profile Image
                    profileImageView
                        .frame(width: geometry.size.width * 0.4,
                               height: geometry.size.width * 0.4)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .shadow(radius: 10)
                        .padding(.top, 30)

                    // MARK: - Name + Age
                    Text("\(user.name), \(user.age)")
                        .font(.system(size: geometry.size.width * 0.06, weight: .bold))
                        .foregroundColor(.white)

                    // MARK: - Location
                    Text(user.location)
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    // MARK: - Bio Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("About")
                            .font(.headline)
                            .foregroundColor(.white)

                        Text(user.bio)
                            .font(.body)
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                   
                    .cornerRadius(16)
                    .padding(.horizontal, geometry.size.width * 0.08)
                    
                    Spacer()
                    Spacer()
                    // MARK: - Action Buttons (Static Icons)
                    if user.id != session.uid {
                        HStack(spacing: 20) {
                            switch requestVM.status {
                            case .none:
                                Button {
                                    Task {
                                        await requestVM.sendRequest(to: user, from: UserModel(
                                            id: session.uid,
                                            name: session.name, 
                                            age: session.age,
                                            location: session.location,
                                            bio: session.bio,
                                            profileImageUrl: nil
                                        ))
                                    }
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.green)
                                        .padding()
                                        .background(Color.white.opacity(0.1))
                                        .clipShape(Circle())
                                }


                            case .sent:
                                HStack(spacing: 20) {
                                    // 🟠 Hourglass Icon
                                    Image(systemName: "hourglass")
                                        .foregroundColor(.orange)
                                        .padding()
                                        .background(Color.white.opacity(0.1))
                                        .clipShape(Circle())

                                    // ❌ Cancel Button
                                    Button {
                                        Task {
                                            await requestVM.cancelRequest(currentUserId: session.uid, to: user.id)
                                        }
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                            .padding()
                                            .background(Color.white.opacity(0.1))
                                            .clipShape(Circle())
                                    }
                                }


                            case .accepted:
                                Button {
                                    Task {
                                        // Step 1: Create a unique and consistent chatId
                                        let chatVM = ChatSessionViewModel()
                                        let chatId = chatVM.computeChatId(session.uid, user.id)


                                        // Step 2: Create Chat if not exists
                                      
                                        await chatVM.createChatIfNotExists(
                                            chatId: chatId,
                                            senderId: session.uid,
                                            receiverId: user.id,
                                            senderName: session.name,
                                            receiverName: user.name,
                                            senderImage: session.profileImageUrl,
                                            receiverImage: user.profileImageUrl
                                        )

                                        // Step 3: Navigate to ChatView using appRouter
                                        appRouter.goToChat(with: chatId)
                                    }
                                } label: {
                                    Image(systemName: "message.fill")
                                        .foregroundColor(.blue)
                                        .padding()
                                        .background(Color.white.opacity(0.1))
                                        .clipShape(Circle())
                                }

                            case .received:
                                HStack(spacing: 20) {
                                    Button {
                                        Task{ await requestVM.acceptRequest(currentUserId:session.uid, from:user.id)}
                                    } label: {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .padding()
                                            .background(Color.white.opacity(0.1))
                                            .clipShape(Circle())
                                    }

                                    Button {
                                        Task{ await requestVM.declineRequest(currentUserId:session.uid, from:user.id)}
                                        print("❌ Decline Request")
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                            .padding()
                                            .background(Color.white.opacity(0.1))
                                            .clipShape(Circle())
                                    }
                                }
                            }
                        }.padding(.top, 10)

                    }

                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 40)
            }
            .background(Color(.bgc))
        }
        .onAppear{
            Task{
                await requestVM.checkStatus(currentUserId: session.uid, viewedUserId: user.id)
            }
        }

    }

    // MARK: - Profile Image View
    private var profileImageView: some View {
        if let urlStr = user.profileImageUrl,
           let url = URL(string: urlStr),
           !urlStr.isEmpty {
            return AnyView(
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Image("profile")
                        .resizable().scaledToFill()
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

#Preview {
    NavigationStack {
        UserProfileView(user: UserModel(
            id: "sampleID",
            name: "Alex",
            age: 22,
            location: "New York",
            bio: "Lover of books and boba tea 🍵",
            profileImageUrl: nil
        ))
        .environmentObject(UserSession.shared)
        
    }
}
