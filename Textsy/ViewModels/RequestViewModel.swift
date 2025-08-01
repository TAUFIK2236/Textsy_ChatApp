//
//  RequestViewModel.swift
//  Textsy
//
//  Created by Anika Tabasum on 7/26/25.
//


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
            await saveNotification(
                senderId: currentUser.id,
                senderName: currentUser.name,
                senderImageUrl: currentUser.profileImageUrl,
                receiverId: user.id,
                type: "request",
                message: "sent you a chat request"
            )

        } catch {
            errorMessage = "❌ Request failed: \(error.localizedDescription)"
        }

        isLoading = false
    }
    
    
    
    func acceptRequest(currentUserId: String, from senderId: String) async {
        isLoading = true
        errorMessage = ""

        let chatData: [String: Any] = [
            "participants": [currentUserId, senderId],
            "lastMessage": "",
            "timeStamp": Timestamp(date: Date()),
            "unreadCount": 0,
            "userName": "", // fill if needed
            "profileImageURL": "" // optional
        ]

        do {
            // 1. Create new chat
            try await db.collection("chats").addDocument(data: chatData)
            status = .accepted
            print("📦 Trying to fetch user info for ID: \(currentUserId)")
            if let userInfo = await fetchCurrentUserInfo(uid: currentUserId) {
                print("✅ Got user info: \(userInfo.name) — Now saving notification...")
                await saveNotification(
                    senderId: currentUserId,
                    senderName: userInfo.name,
                    senderImageUrl: userInfo.imageUrl,
                    receiverId: senderId,
                    type: "accepted", // or "declined"
                    message: "accepted your chat request"
                )
                print("📤 Notification saved for receiver: \(senderId)")
            } else {
                print("❌ Could not fetch user info — no notification saved")
            }


            // 2. Delete the request
            let snapshot = try await db.collection("requests")
                .whereField("senderId", isEqualTo: senderId)
                .whereField("receiverId", isEqualTo: currentUserId)
                .getDocuments()

            for doc in snapshot.documents {
                try await doc.reference.delete()
            }

            status = .accepted
        } catch {
            errorMessage = "Accept failed: \(error.localizedDescription)"
        }

        isLoading = false
    }

    
    
    func declineRequest(currentUserId: String, from senderId: String) async {
        isLoading = true
        errorMessage = ""

        do {
            let snapshot = try await db.collection("requests")
                .whereField("senderId", isEqualTo: senderId)
                .whereField("receiverId", isEqualTo: currentUserId)
                .getDocuments()

            for doc in snapshot.documents {
                try await doc.reference.delete()
            }
           status = .none
            
            if let userInfo = await fetchCurrentUserInfo(uid: currentUserId) {
                await saveNotification(
                    senderId: currentUserId,
                    senderName: userInfo.name,
                    senderImageUrl: userInfo.imageUrl,
                    receiverId: senderId,
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
        isLoading = true
        errorMessage = ""

        do {
            let snapshot = try await db.collection("requests")
                .whereField("senderId", isEqualTo: currentUserId)
                .whereField("receiverId", isEqualTo: receiverId)
                .getDocuments()

            for doc in snapshot.documents {
                try await doc.reference.delete()
            }

            status = .none
            print("✅ Request cancelled")
        } catch {
            errorMessage = "Cancel failed: \(error.localizedDescription)"
        }

        isLoading = false
    }
    
    //----------------------------------------------------for notificationview
    @Published var incomingRequests: [RequestModel] = []

    func listenForIncomingRequests(for userId: String) {
        db.collection("requests")
            .whereField("receiverId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, error in
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
            print("❌ Failed to fetch user info: \(error.localizedDescription)")
            return nil
        }
    }


    
    
    
    
   //----------------------------------Notification saving func
    func saveNotification(
        senderId: String,
        senderName: String,
        senderImageUrl: String?,
        receiverId: String,
        type: String,
        message: String
    ) async {
        let notification: [String: Any] = [
            "senderId": senderId,
            "receiverId": receiverId,
            "senderName": senderName,
            "senderImageUrl": senderImageUrl ?? "",
            "type": type,
            "message": message,
            "timestamp": Timestamp(date: Date())
        ]

        do {
            try await db.collection("notifications").addDocument(data: notification)
            print("✅ Notification saved: \(type)")
        } catch {
            print("❌ Failed to save notification: \(error.localizedDescription)")
        }
    }

}

