
//this one foe home page

import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class ChatViewModel: ObservableObject {
    @Published var chats: [ChatModel] = []
    @Published var errorMessage = ""

    // 🧠 Load chats from Firestore
    func listenToChats(for userId: String) {
        Firestore.firestore()
            .collection("chats")
            .whereField("participants", arrayContains: userId)
            .order(by: "timeStamp", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    self.errorMessage = "❌ Listener failed: \(error.localizedDescription)"
                    return
                }

                guard let docs = snapshot?.documents else {
                    self.errorMessage = "❌ No chat documents found"
                    return
                }

                self.chats = docs.compactMap { doc in
                    ChatModel(id: doc.documentID, data: doc.data())
                }

                print("📡 Live chat list updated with \(self.chats.count) chats")
            }
    }



//    func debugChatsOnce() {
//        guard let uid = Auth.auth().currentUser?.uid else {
//            print("❌ No current user")
//            return
//        }
//        print("🔎 Debug UID:", uid)
//
//        let db = Firestore.firestore()
//        db.collection("chats")
//            .whereField("participants", arrayContains: uid)
//            .order(by: "timeStamp", descending: true)   // keep this; index is ready
//            .limit(to: 20)
//            .getDocuments { snap, err in
//                if let err = err {
//                    print("❌ Query error:", err.localizedDescription)
//                    return
//                }
//                let count = snap?.documents.count ?? 0
//                print("📦 Server returned docs:", count)
//
//                snap?.documents.forEach { doc in
//                    let data = doc.data()
//                    print("— id:", doc.documentID)
//                    print("  participants:", data["participants"] ?? "nil")
//                    print("  timeStamp:", data["timeStamp"] ?? "nil")
//                    print("  lastMessage:", data["lastMessage"] ?? "nil")
//                }
//            }
//    }

    
}
