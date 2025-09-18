//import SwiftUI
//import FirebaseFirestore
//
//struct SettingView: View {
//    @EnvironmentObject var session: UserSession
//    @EnvironmentObject var appRouter: AppRouter
//    @AppStorage("isDarkMode") private var isDarkMode = true
//    @State private var notificationsOn = true
//    @State private var showDeleteAlert = false
//    @State private var isDeleting = false
//    @State private var isDrawerOpen = false // 👈 our own drawer state!
//    
//    @State private var showToast = false
//    @State private var toastMessage = ""
//    @StateObject private var profileVM = UserProfileViewModel()
//    @State private var blockedUsers: [UserModel] = []
//
//    var body: some View {
//        ZStack {
//            VStack(spacing: 30) {
//                // 🔝 Top AppBar
//                HStack {
//                    Button {
//                        isDrawerOpen.toggle()
//                    } label: {
//                        Image(systemName: "line.3.horizontal")
//                            .font(.title.bold())
//                            .foregroundColor(.white)
//                            .padding(10)
//                            .background(Color.white.opacity(0.1))
//                            .clipShape(Circle())
//                    }
//
//                    Spacer()
//
//                    Text("Settings")
//                        .font(.title.bold())
//                        .foregroundColor(.white)
//
//                    Spacer()
//                }
//                .padding(.horizontal)
//                .padding(.top)
//
//                // 🌙 Dark Mode Toggle
//                Toggle("Dark Mode", isOn: $isDarkMode)
//                    .toggleStyle(SwitchToggleStyle(tint: .blue))
//                    .padding()
//                    .background(Color(.fieldT))
//                    .cornerRadius(10)
//                    .foregroundColor(.white)
//
//                // 🔔 Notification Toggle
//                Toggle("Push Notifications", isOn: $notificationsOn)
//                    .toggleStyle(SwitchToggleStyle(tint: .green))
//                    .padding()
//                    .background(Color(.fieldT))
//                    .cornerRadius(10)
//                    .foregroundColor(.white)
//
//                // 🚫 Blocked Users List
//                if !blockedUsers.isEmpty {
//                    VStack(alignment: .leading, spacing: 10) {
//                        Text("Blocked Users")
//                            .font(.headline)
//                            .foregroundColor(.white)
//
//                        ForEach(blockedUsers) { user in
//                            HStack {
//                                if let url = URL(string: user.profileImageUrl ?? "") {
//                                    AsyncImage(url: url) { image in
//                                        image.resizable().scaledToFill()
//                                    } placeholder: {
//                                        Color.gray
//                                    }
//                                    .frame(width: 40, height: 40)
//                                    .clipShape(Circle())
//                                }
//
//                                VStack(alignment: .leading) {
//                                    Text(user.name)
//                                        .foregroundColor(.white)
//                                        .font(.subheadline.bold())
//                                    Text(user.location)
//                                        .foregroundColor(.gray)
//                                        .font(.caption)
//                                }
//
//                                Spacer()
//
//                                Button("Unblock") {
//                                    Task {
//                                        await profileVM.unblockUser(targetId: user.id)
//                                        toastMessage = "Unblocked \(user.name)"
//                                        showToast = true
//                                        await loadBlockedUsers()
//                                    }
//                                }
//                                .font(.caption)
//                                .padding(6)
//                                .background(Color.red.opacity(0.2))
//                                .foregroundColor(.red)
//                                .cornerRadius(8)
//                            }
//                        }
//                    }
//                    .padding()
//                    .background(Color(.fieldT))
//                    .cornerRadius(10)
//                }
//
//                // 🗑️ Delete Account
//                Button(role: .destructive) {
//                    showDeleteAlert = true
//                } label: {
//                    HStack {
//                        Image(systemName: "trash")
//                        Text("Delete Account")
//                    }
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.red.opacity(0.2))
//                    .cornerRadius(12)
//                    .foregroundColor(.red)
//                }
//                .padding(.top, 10)
//
//                Spacer()
//            }
//            .padding()
//            .background(Color(.bgc))
//            .blur(radius: isDrawerOpen ? 8 : 0)
//            .onAppear {
//                Task {
//                    await loadBlockedUsers()
//                }
//            }
//
//            .overlay(
//                VStack {
//                    if showToast {
//                        Text(toastMessage)
//                            .font(.subheadline)
//                            .foregroundColor(.white)
//                            .padding()
//                            .background(Color.black.opacity(0.8))
//                            .cornerRadius(10)
//                            .padding(.top, 50)
//                            .transition(.move(edge: .top).combined(with: .opacity))
//                            .onAppear {
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                                    showToast = false
//                                }
//                            }
//                    }
//                    Spacer()
//                }, alignment: .top
//            )
//
//            // 🧠 Drawer Overlay
//            .overlay(
//                SideDrawerView(
//                    isOpen: $isDrawerOpen,
//                    currentPage: appRouter.currentPage,
//                    goTo: { page in withAnimation { appRouter.currentPage = page; isDrawerOpen = false } },
//                    onLogout: { UserSession.shared.clear(); isDrawerOpen = false },
//                    onExit: { exit(0) }
//                )
//                .transition(.move(edge: .leading))
//                .animation(.easeInOut, value: isDrawerOpen)
//                .opacity(isDrawerOpen ? 1 : 0)
//            )
//        }
//        .alert("Are you sure?", isPresented: $showDeleteAlert) {
//            Button("Cancel", role: .cancel) {}
//            Button("Delete", role: .destructive) {
//                Task {
//                    await deleteAccount()
//                }
//            }
//        } message: {
//            Text("This will permanently delete your account and all data.")
//        }
//    }
//
//    // 🔄 Load blocked users
//    func loadBlockedUsers() async {
//        let uid = session.uid 
//        let db = Firestore.firestore()
//        do {
//            let meDoc = try await db.collection("users").document(uid).getDocument()
//            let myBlocked = meDoc["blocked"] as? [String] ?? []
//            let allUsersSnapshot = try await db.collection("users").getDocuments()
//            let users = allUsersSnapshot.documents.compactMap { UserModel(id: $0.documentID, data: $0.data()) }
//            self.blockedUsers = users.filter { myBlocked.contains($0.id) }
//        } catch {
//            toastMessage = "⚠️ Failed to load blocked list"
//            showToast = true
//        }
//    }
//
//    // 🧨 Delete from Firebase
//    func deleteAccount() async {
//        isDeleting = true
//        await AuthViewModel().deleteUser()
//        isDeleting = false
//    }
//}
import SwiftUI
import FirebaseFirestore

struct SettingView: View {
    @EnvironmentObject var session: UserSession
    @EnvironmentObject var appRouter: AppRouter
    @AppStorage("isDarkMode") private var isDarkMode = true
    @State private var notificationsOn = true
    @State private var showDeleteAlert = false
    @State private var isDeleting = false
    @State private var isDrawerOpen = false
    
    @State private var showToast = false
    @State private var toastMessage = ""
    @StateObject private var profileVM = UserProfileViewModel()
    @State private var blockedUsers: [UserModel] = []

    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                // 🔝 Top Bar
                HStack {
                    Button {
                        isDrawerOpen.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.title.bold())
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }

                    Spacer()

                    Text("Settings")
                        .font(.title.bold())
                        .foregroundColor(.white)

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)

                // 🌙 Dark Mode Toggle
                Toggle("Dark Mode", isOn: $isDarkMode)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    .padding()
                    .background(Color(.fieldT))
                    .cornerRadius(10)
                    .foregroundColor(.white)

                // 🔔 Notifications Toggle
                Toggle("Push Notifications", isOn: $notificationsOn)
                    .toggleStyle(SwitchToggleStyle(tint: .green))
                    .padding()
                    .background(Color(.fieldT))
                    .cornerRadius(10)
                    .foregroundColor(.white)

                // 🚫 Blocked Users List
                if !blockedUsers.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Blocked Users")
                            .font(.headline)
                            .foregroundColor(.white)

                        ForEach(blockedUsers) { user in

                            Text("Blocked users: \(blockedUsers.count)")//this need a page

                        }
                    }
                    .padding()
                    .background(Color(.fieldT))
                    .cornerRadius(10)
                }

                // 🗑️ Delete Account
                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete Account")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.2))
                    .cornerRadius(12)
                    .foregroundColor(.red)
                }
                .padding(.top, 10)

                Spacer()
            }
            .padding()
            .background(Color(.bgc))
            .blur(radius: isDrawerOpen ? 8 : 0)
            .onAppear {
                Task { await loadBlockedUsers() }
            }

            // 🔔 Toast Message
            .overlay(
                VStack {
                    if showToast {
                        Text(toastMessage)
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.8))
                            .cornerRadius(10)
                            .padding(.top, 50)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    showToast = false
                                }
                            }
                    }
                    Spacer()
                }, alignment: .top
            )

            // 🧠 Side Drawer
            .overlay(
                SideDrawerView(
                    isOpen: $isDrawerOpen,
                    currentPage: appRouter.currentPage,
                    goTo: { page in withAnimation { appRouter.currentPage = page; isDrawerOpen = false } },
                    onLogout: { UserSession.shared.clear(); isDrawerOpen = false },
                    onExit: { exit(0) }
                )
                .transition(.move(edge: .leading))
                .animation(.easeInOut, value: isDrawerOpen)
                .opacity(isDrawerOpen ? 1 : 0)
            )
        }
        .alert("Are you sure?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task { await deleteAccount() }
            }
        } message: {
            Text("This will permanently delete your account and all data.")
        }
    }

    // 🔄 Load blocked users
    func loadBlockedUsers() async {
        let uid = session.uid
        let db = Firestore.firestore()
        do {
            let meDoc = try await db.collection("users").document(uid).getDocument()
            let myBlocked = meDoc["blocked"] as? [String] ?? []
            let allUsersSnapshot = try await db.collection("users").getDocuments()
            let users = allUsersSnapshot.documents.compactMap { UserModel(id: $0.documentID, data: $0.data()) }
            self.blockedUsers = users.filter { myBlocked.contains($0.id) }
        } catch {
            toastMessage = "⚠️ Failed to load blocked list"
            showToast = true
        }
    }

    // 🧨 Delete account
    func deleteAccount() async {
        isDeleting = true
        await AuthViewModel().deleteUser()
        isDeleting = false
    }
}


struct BlockedUserRow: View {
    let user: UserModel
    let unblock: () -> Void

    var body: some View {
        HStack {
            if let url = URL(string: user.profileImageUrl ?? "") {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            }

            VStack(alignment: .leading) {
                Text(user.name)
                    .foregroundColor(.white)
                    .font(.subheadline.bold())
                Text(user.location)
                    .foregroundColor(.gray)
                    .font(.caption)
            }

            Spacer()

            Button("Unblock") {
                unblock() // ✅ NOT async
            }
            .font(.caption)
            .padding(6)
            .background(Color.red.opacity(0.2))
            .foregroundColor(.red)
            .cornerRadius(8)
        }
    }
}
