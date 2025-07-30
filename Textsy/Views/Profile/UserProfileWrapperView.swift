import SwiftUI
import FirebaseFirestore

struct UserProfileWrapperView: View {
    let userId: String
    @EnvironmentObject var session: UserSession
    @EnvironmentObject var appRouter: AppRouter 
    @State private var user: UserModel? = nil
    @State private var isLoading = true
    @State private var error: String? = nil

    var body: some View {
        Group {
            if isLoading {
                LoadingCircleView()
            } else if let error = error {
                Text("❌ \(error)")
                    .foregroundColor(.red)
            } else if let user = user {
                UserProfileView(user: user)
                    .environmentObject(session)
                    .environmentObject(appRouter)
            } else {
                Text("❌ User not found.")
                    .foregroundColor(.red)
            }
        }
        .task {
            await fetchUser()
        }
    }

    private func fetchUser() async {
        isLoading = true
        error = nil
        user = nil

        do {
            let doc = try await Firestore.firestore()
                .collection("users")
                .document(userId)
                .getDocument()

            guard let data = doc.data() else {
                error = "No user data found."
                return
            }

            guard let loadedUser = UserModel(id: userId, data: data) else {
                error = "User model couldn't be built."
                return
            }

            self.user = loadedUser
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }
}
