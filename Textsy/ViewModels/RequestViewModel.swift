import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class RequestViewModel: ObservableObject {
    enum RequestStatus {
        case none
        case sent
        case received
        case accepted
    }

    @Published var status: RequestStatus = .none
    @Published var isLoading = false
    @Published var errorMessage = ""

    private let db = Firestore.firestore()

    func checkStatus(currentUserId: String, viewedUserId: String) async {
        isLoading = true
        errorMessage = ""

        // 1. Check for accepted match (chat already exists)
        let chatQuery = db.collection("chats")
            .whereField("participants", arrayContains: currentUserId)

        do {
            let snapshot = try await chatQuery.getDocuments()
            for doc in snapshot.documents {
                let participants = doc["participants"] as? [String] ?? []
                if participants.contains(viewedUserId) {
                    status = .accepted
                    isLoading = false
                    return
                }
            }
        } catch {
            errorMessage = "Chat check failed: \(error.localizedDescription)"
        }

        // 2. Check for sent request
        let sent = try? await db.collection("requests")
            .whereField("senderId", isEqualTo: currentUserId)
            .whereField("receiverId", isEqualTo: viewedUserId)
            .getDocuments()

        if let sent = sent, !sent.isEmpty {
            status = .sent
            isLoading = false
            return
        }

        // 3. Check for received request
        let received = try? await db.collection("requests")
            .whereField("senderId", isEqualTo: viewedUserId)
            .whereField("receiverId", isEqualTo: currentUserId)
            .getDocuments()

        if let received = received, !received.isEmpty {
            status = .received
            isLoading = false
            return
        }

        // 4. No request found
        status = .none
        isLoading = false
    }

    func sendRequest(to user: UserModel, from currentUser: UserModel) async {
        isLoading = true
        errorMessage = ""

        let request = [
            "senderId": currentUser.id,
            "receiverId": user.id,
            "name": currentUser.name,
            "age": currentUser.age,
            "location": currentUser.location,
            "bio": currentUser.bio,
            "profileImageUrl": currentUser.profileImageUrl ?? "",
            "timestamp": Timestamp(date: Date())
        ] as [String : Any]

        do {
            try await db.collection("requests").addDocument(data: request)
            status = .sent
        } catch {
            errorMessage = "❌ Request failed: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
