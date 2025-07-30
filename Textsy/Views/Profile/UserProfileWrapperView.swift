import SwiftUI
import FirebaseFirestore

struct UserProfileWrapperView: View {
    let userId: String
    @State private var user: UserModel? = nil
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                LoadingCircleView()
            } else if let user = user {
                UserProfileView(user: user)
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
        do {
            let doc = try await Firestore.firestore()
                .collection("users")
                .document(userId)
                .getDocument()

            if let data = doc.data() {
                self.user = UserModel(id: userId, data: data)
            }
        } catch {
            print("❌ Failed to fetch user: \(error.localizedDescription)")
        }
        self.isLoading = false
    }
}
