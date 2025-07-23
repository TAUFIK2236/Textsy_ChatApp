//
//  AuthViewModel.swift
//  Textsy
//
//  Created by Anika Tabasum on 7/18/25.
//


import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthViewModel: ObservableObject {
    static let shared = AuthViewModel()
    private init() {}

    // MARK: - Input fields
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    
    // MARK: - User Related
    @Published var currentUser: UserModel? = nil
    

    // MARK: - UI feedback
    @Published var isLoading = false
    @Published var alertMessage: String? = nil
    @Published var showAlert = false

    // MARK: - Firebase & Firestore
    private let auth = Auth.auth()
    private let db = Firestore.firestore()

    // MARK: - Login
    func login() async {
        resetState()
        guard validateEmailAndPassword() else { return }

        isLoading = true
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            UserSession.shared.updateUser(with: result.user)
            saveToken(uid: result.user.uid)
            AppRouter.shared.goToMainApp()
        } catch {
            show(error: error)
        }
        isLoading = false
    }

    // MARK: - Signup
    func signup() async {
        resetState()
        guard validateEmailAndPassword(), validatePasswordsMatch() else { return }

        isLoading = true
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            let uid = result.user.uid

            try await db.collection("users").document(uid).setData([
                "email": email,
                "createdAt": FieldValue.serverTimestamp(),
                "name": "", // ← important for ProfileView check
                "age": 0,
                "location": "",
                "bio": "",
                "profileImageUrl": ""
            ])

            //  FETCH profile and update session
            let snapshot = try await db.collection("users").document(uid).getDocument()
            if let data = snapshot.data() {
                let model = UserModel(data)
                UserSession.shared.updateUser(with: result.user) // for Auth
                UserSession.shared.currentUser = result.user
                self.currentUser = model// for Profile check
                saveToken(uid: uid)
                DispatchQueue.main.async {
                    AppRouter.shared.goToMainApp()
                }
            } else {
                show(message: "Could not load profile.")
            }

        } catch {
            show(error: error)
        }
        isLoading = false
    }


    // MARK: - Password Reset
    func resetPassword() async {
        resetState()
        guard !email.isEmpty else {
            show(message: "Enter your email.")
            return
        }

        isLoading = true
        do {
            try await auth.sendPasswordReset(withEmail: email)
            DispatchQueue.main.async {
                self.show(message: "Reset link sent. Check your email.")
                AppRouter.shared.goToLogin()
            }

        } catch {
            show(error: error)
        }
        isLoading = false
    }

    // MARK: - Logout
    func logout() {
        do {
            try auth.signOut()
            clearToken()
            UserSession.shared.logout()
            AppRouter.shared.goToLogin()
        } catch {
            show(message: "Logout failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Delete Account (Everything)
    func deleteAccount() async {
        resetState()
        guard let user = auth.currentUser else {
            show(message: "No user found.")
            return
        }

        isLoading = true
        let uid = user.uid

        do {
            // Delete all related data
            try await deleteUserDataFromFirestore(uid: uid)

            // Delete auth user
            try await user.delete()

            clearToken()
            UserSession.shared.logout()
            AppRouter.shared.goToLogin()
        } catch {
            show(error: error)
        }
        isLoading = false
    }

    // MARK: - Delete all Firestore data linked to user
    private func deleteUserDataFromFirestore(uid: String) async throws {
        // Delete user profile
        try await db.collection("users").document(uid).delete()

        // Delete chats created by or with user
        let chatDocs = try await db.collection("chats").whereField("userIds", arrayContains: uid).getDocuments()
        for doc in chatDocs.documents {
            try await doc.reference.delete()
        }

        // Delete messages sent by user
        let messageDocs = try await db.collection("messages").whereField("senderId", isEqualTo: uid).getDocuments()
        for doc in messageDocs.documents {
            try await doc.reference.delete()
        }

        // Delete requests, notifications, etc. if any
        // You can repeat the same pattern for other collections
    }

    // MARK: - Helpers
    private func validateEmailAndPassword() -> Bool {
        if email.isEmpty || password.isEmpty {
            show(message: "Email and password required.")
            return false
        }
        return true
    }

    private func validatePasswordsMatch() -> Bool {
        if password != confirmPassword {
            show(message: "Passwords do not match.")
            return false
        }
        return true
    }

    private func show(error: Error) {
        print("❌ Firebase Raw Error:", error)
        alertMessage = error.localizedDescription
        showAlert = true
    }



    private func show(message: String) {
        alertMessage = message
        showAlert = true
    }

    private func resetState() {
        alertMessage = nil
        showAlert = false
        isLoading = false
    }

    // MARK: - Token Save/Clear
    private func saveToken(uid: String) {
        UserDefaults.standard.set(uid, forKey: "userUID")
    }

    private func clearToken() {
        UserDefaults.standard.removeObject(forKey: "userUID")
    }
    
    // MARK: - Upadate the profile(Save change button in ProfileEditView)
    func updateProfile(name: String, age: String, location: String, bio: String) async {
        resetState()
        guard let uid = auth.currentUser?.uid else {
            show(message: "User not logged in.")
            return
        }

        isLoading = true
        do {
            try await db.collection("users").document(uid).updateData([
                "name": name,
                "age": Int(age)!,
                "location": location,
                "bio": bio
            ])
            show(message: "Changes saved successfully!")
        } catch {
            show(error: error)
        }
        isLoading = false
    }


    func fetchUserProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(uid).getDocument { snapshot, error in
            self.isLoading = false
            if let data = snapshot?.data() {
                self.currentUser = UserModel(data)
            } else {
                self.alertMessage = "Failed to load profile."
                self.showAlert = true
            }
        }
    }


}
