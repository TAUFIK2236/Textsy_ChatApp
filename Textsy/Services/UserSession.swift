//
//  UserSession.swift
//  Textsy
//
//  Created by Anika Tabasum on 7/18/25.
//


import Foundation
import FirebaseAuth

@MainActor
class UserSession: ObservableObject {
    static let shared = UserSession()
    private init() {}

    @Published var currentUser: User?

    var isLoggedIn: Bool {
        return currentUser != nil
    }

    func updateUser(with user: User?) {
        self.currentUser = user
    }

    func logout() {
        try? Auth.auth().signOut()
        currentUser = nil
    }
}
