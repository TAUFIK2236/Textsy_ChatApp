
import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class RequestViewModel: ObservableObject {
    enum RequestStatus {
        case none, sent, received, accepted
    }

    @Published var status: RequestStatus = .none
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var incomingRequests: [RequestModel] = []

    private let db = Firestore.firestore()

    func checkStatus(currentUserId: String, viewedUserId: String) async {
        isLoading = true; errorMessage = ""
        do {
            let snapshot = try await db.collection("chats")
                .whereField("participants", arrayContains: currentUserId)
                .getDocuments()
            for doc in snapshot.documents {
                if (doc["participants"] as? [String] ?? []).contains(viewedUserId) {
                    status = .accepted; isLoading = false; return
                }
            }
        } catch { errorMessage = "Chat check failed: \(error.localizedDescription)" }

        if let sent = try? await db.collection("requests")
            .whereField("senderId", isEqualTo: currentUserId)
            .whereField("receiverId", isEqualTo: viewedUserId)
            .getDocuments(), !sent.isEmpty {
            status = .sent; isLoading = false; return
        }

        if let received = try? await db.collection("requests")
            .whereField("senderId", isEqualTo: viewedUserId)
            .whereField("receiverId", isEqualTo: currentUserId)
            .getDocuments(), !received.isEmpty {
            status = .received; isLoading = false; return
        }

        status = .none; isLoading = false
    }

    func sendRequest(to user: UserModel, from currentUser: UserModel) async {
        isLoading = true; errorMessage = ""
        let request: [String: Any] = [
            "senderId": currentUser.id,
            "receiverId": user.id,
            "senderName": currentUser.name,
            "receiverName": user.name,
            "age": currentUser.age,
            "location": currentUser.location,
            "bio": currentUser.bio,
            "profileImageUrl": currentUser.profileImageUrl ?? "",
            "timestamp": Timestamp(date: Date())
        ]
        do {
            try await db.collection("requests").addDocument(data: request)
            status = .sent
            let notifId = [currentUser.id, user.id, "request"].sorted().joined(separator: "_")
            await saveNotification(
                id: notifId,
                senderId: currentUser.id,
                senderName: currentUser.name,
                senderImageUrl: currentUser.profileImageUrl,
                receiverId: user.id,
                receiverName: user.name,
                type: "request",
                message: "sent you a chat request"
            )
        } catch {
            errorMessage = "❌ Request failed: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func acceptRequest(currentUserId: String, from senderId: String) async {
        isLoading = true; errorMessage = ""
        let chatData: [String: Any] = [
            "participants": [currentUserId, senderId],
            "lastMessage": "",
            "timeStamp": Timestamp(date: Date()),
            "unreadCount": 0,
            "userName": "",
            "profileImageURL": ""
        ]
        do {
            try await db.collection("chats").addDocument(data: chatData)
            status = .accepted
            if let userInfo = await fetchCurrentUserInfo(uid: currentUserId),
               let senderInfo = await fetchCurrentUserInfo(uid: senderId) {
                let notifId = [currentUserId, senderId, "accepted"].sorted().joined(separator: "_")
                await saveNotification(
                    id: notifId,
                    senderId: currentUserId,
                    senderName: userInfo.name,
                    senderImageUrl: userInfo.imageUrl,
                    receiverId: senderId,
                    receiverName: senderInfo.name,
                    type: "accepted",
                    message: "accepted your chat request"
                )
            }
            let snapshot = try await db.collection("requests")
                .whereField("senderId", isEqualTo: senderId)
                .whereField("receiverId", isEqualTo: currentUserId)
                .getDocuments()
            for doc in snapshot.documents { try await doc.reference.delete() }
        } catch {
            errorMessage = "Accept failed: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func declineRequest(currentUserId: String, from senderId: String) async {
        isLoading = true; errorMessage = ""
        do {
            let snapshot = try await db.collection("requests")
                .whereField("senderId", isEqualTo: senderId)
                .whereField("receiverId", isEqualTo: currentUserId)
                .getDocuments()
            for doc in snapshot.documents { try await doc.reference.delete() }
            status = .none
            if let userInfo = await fetchCurrentUserInfo(uid: currentUserId),
               let senderInfo = await fetchCurrentUserInfo(uid: senderId) {
                let notifId = [currentUserId, senderId, "declined"].sorted().joined(separator: "_")
                await saveNotification(
                    id: notifId,
                    senderId: currentUserId,
                    senderName: userInfo.name,
                    senderImageUrl: userInfo.imageUrl,
                    receiverId: senderId,
                    receiverName: senderInfo.name,
                    type: "declined",
                    message: "declined your chat request"
                )
            }
        } catch {
            errorMessage = "Decline failed: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func cancelRequest(currentUserId: String, to receiverId: String) async {
        isLoading = true; errorMessage = ""
        do {
            let snapshot = try await db.collection("requests")
                .whereField("senderId", isEqualTo: currentUserId)
                .whereField("receiverId", isEqualTo: receiverId)
                .getDocuments()
            for doc in snapshot.documents { try await doc.reference.delete() }
            status = .none
            if let current = await fetchCurrentUserInfo(uid: currentUserId),
               let receiver = await fetchCurrentUserInfo(uid: receiverId) {
                let notifId = [currentUserId, receiverId, "declined"].sorted().joined(separator: "_")
                await saveNotification(
                    id: notifId,
                    senderId: currentUserId,
                    senderName: current.name,
                    senderImageUrl: current.imageUrl,
                    receiverId: receiverId,
                    receiverName: receiver.name,
                    type: "declined",
                    message: "cancelled the chat request"
                )
            }
        } catch {
            errorMessage = "Cancel failed: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func listenForIncomingRequests(for userId: String) {
        db.collection("requests")
            .whereField("receiverId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                self.incomingRequests = docs.compactMap { doc in
                    RequestModel(id: doc.documentID, data: doc.data())
                }
            }
    }

    func fetchCurrentUserInfo(uid: String) async -> (name: String, imageUrl: String?)? {
        do {
            let doc = try await db.collection("users").document(uid).getDocument()
            let data = doc.data()
            let name = data?["name"] as? String ?? ""
            let image = data?["profileImageUrl"] as? String
            return (name, image)
        } catch {
            print("❌ Failed to fetch user info: \(error.localizedDescription)"); return nil
        }
    }

    func saveNotification(
        id: String,
        senderId: String,
        senderName: String,
        senderImageUrl: String?,
        receiverId: String,
        receiverName: String,
        type: String,
        message: String
    ) async {
        let notification: [String: Any] = [
            "senderId": senderId,
            "receiverId": receiverId,
            "senderName": senderName,
            "receiverName": receiverName,
            "senderImageUrl": senderImageUrl ?? "",
            "type": type,
            "message": message,
            "timestamp": Timestamp(date: Date())
        ]
        do { try await db.collection("notifications").document(id).setData(notification) }
        catch { print("❌ Failed to save notification: \(error.localizedDescription)") }
    }
}
