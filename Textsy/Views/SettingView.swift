import SwiftUI

struct SettingView: View {
    @EnvironmentObject var session: UserSession
    @EnvironmentObject var appRouter: AppRouter
    @AppStorage("isDarkMode") private var isDarkMode = true
    @State private var notificationsOn = true
    @State private var showDeleteAlert = false
    @State private var isDeleting = false
    @State private var isDrawerOpen = false // 👈 our own drawer state!

    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                // 🔝 Top AppBar
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

                // 🔔 Notification Toggle
                Toggle("Push Notifications", isOn: $notificationsOn)
                    .toggleStyle(SwitchToggleStyle(tint: .green))
                    .padding()
                    .background(Color(.fieldT))
                    .cornerRadius(10)
                    .foregroundColor(.white)

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

            // 🧠 Drawer Overlay
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
                Task {
                    await deleteAccount()
                }
            }
        } message: {
            Text("This will permanently delete your account and all data.")
        }
    }

    // 🧨 Delete from Firebase
    func deleteAccount() async {
        isDeleting = true
        await AuthViewModel().deleteUser()
        isDeleting = false
    }
}
