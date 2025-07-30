
import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage = ""

    
    // 1. Login Function
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = ""

        do {
            // 1️⃣ Try to sign in with email + password
            let result = try await Auth.auth().signIn(withEmail: email, password: password)

            // 2️⃣ If successful, get the Firebase User
            let user = result.user

            // 3️⃣ Save user info and token to session
            UserSession.shared.loadFromFirebaseUser(user)

            print("✅ Logged in: \(user.email ?? "no email")")

        } catch {
            // ❌ Show error message to user
            errorMessage = error.localizedDescription
            print("❌ Login failed: \(errorMessage)")
        }

        isLoading = false
    }
    
    
    
    

    
    //SIGNUp function
    
    func signup(email:String, password: String) async{
        isLoading = true
        errorMessage = ""
        do{
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            UserSession.shared.loadFromFirebaseUser(result.user)
            print("Accont created: \(result.user.email ?? "")")
        } catch{
            errorMessage = error.localizedDescription
            print("SignUp error: \(errorMessage)")
        }
        isLoading = false
    }
    
    
    //Reset Password fuction
    func resetPassword(email:String) async{
        isLoading = true
        errorMessage = ""
        do{
            try await Auth.auth().sendPasswordReset(withEmail: email)
            print("Reset Email sent to \(email)")
        }catch{
            errorMessage = error.localizedDescription
            print("Reset error: \(errorMessage)")
        }
    }
    
    
    
    // logout function
    func logout() {
        do {
            try Auth.auth().signOut()           // 1️⃣ Logout from Firebase
            UserSession.shared.clear()          // 2️⃣ Clear local session
            print("✅ User logged out")
        } catch {
            print("❌ Logout failed: \(error.localizedDescription)")
        }
    }
    
    


    // 🗑️ DELETE ACCOUNT COMPLETELY
    func deleteUser() async {
        isLoading = true
        errorMessage = ""

        guard let user = Auth.auth().currentUser else {
            errorMessage = "No user is logged in."
            isLoading = false
            return
        }

        let uid = user.uid

        do {
            // 1️⃣ Delete user from Firebase Auth
            try await user.delete()
            print("✅ Firebase user deleted")

            // 2️⃣ Delete user document from Firestore
            try await Firestore.firestore().collection("users").document(uid).delete()
            print("🧹 Firestore data deleted")

            // 3️⃣ Clear local session
            UserSession.shared.clear()

        } catch {
            errorMessage = error.localizedDescription
            print("❌ Delete failed: \(errorMessage)")
        }

        isLoading = false
    }

    
    
}
