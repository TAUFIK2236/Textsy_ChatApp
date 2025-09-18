//import SwiftUI
//import FirebaseFirestore
//
//struct UserProfileWrapperView: View {
//    let userId: String
//    @EnvironmentObject var session: UserSession
//    @EnvironmentObject var appRouter: AppRouter 
//    @State private var user: UserModel? = nil
//    @State private var isLoading = true
//    @State private var error: String? = nil
//    
//
//    var body: some View {
//        Group {
//            if isLoading {
//                LoadingCircleView()
//            } else if let error = error {
//                Text("❌ \(error)")
//                    .foregroundColor(.red)
//            } else if let user = user {
//                UserProfileView(user: user)
//                    .environmentObject(session)
//                    .environmentObject(appRouter)
//            } else {
//                Text("❌ User not found.")
//                    .foregroundColor(.red)
//            }
//        }
//        .task {
//            await fetchUser()
//        }
//    }
//
//    private func fetchUser() async {
//        isLoading = true
//        error = nil
//        user = nil
//
//        do {
//            let db = Firestore.firestore()
//
//            // Check block status
//            let vm = UserProfileViewModel()
//            let blocked = await vm.isBlockedBetween(currentId: session.uid, targetId: userId)
//            if blocked {
//                error = "🚫 This user is not available."
//                return
//            }
//
//            let doc = try await db.collection("users").document(userId).getDocument()
//            guard let data = doc.data() else {
//                error = "No user data found."
//                return
//            }
//
//            guard let loadedUser = UserModel(id: userId, data: data) else {
//                error = "User model couldn't be built."
//                return
//            }
//
//            self.user = loadedUser
//        } catch {
//            self.error = error.localizedDescription
//        }
//
//        isLoading = false
//    }
//
//}
import SwiftUI
import FirebaseFirestore

struct UserProfileWrapperView: View {
    let userId: String
    @EnvironmentObject var session: UserSession
    @EnvironmentObject var appRouter: AppRouter
    @State private var user: UserModel? = nil
    @State private var isLoading = true
    @State private var error: String? = nil

    private let reportBlockVM = ReportBlockViewModel()

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
            let db = Firestore.firestore()

            // ✅ Check if blocked
            let blocked = await reportBlockVM.isBlockedBetween(currentId: session.uid, targetId: userId)
            if blocked {
                error = "🚫 This user is not available."
                return
            }

            let doc = try await db.collection("users").document(userId).getDocument()
            guard let data = doc.data() else {
                error = "No user data found."
                return
            }

            guard let loadedUser = UserModel(id: userId, data: data) else {
                error = "User model couldn't be built."
                return
            }

            // ✅ Check if user is suspended
            if loadedUser.isSuspended {
                error = "🚫 This profile has been suspended."
                return
            }

            self.user = loadedUser
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }
}
