
// ChatViewModel.swift — Home page live chat list with LIMIT + direct Codable cache

import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class ChatViewModel: ObservableObject {
    @Published var chats: [ChatModel] = []
    @Published var errorMessage = ""

    private var listener: ListenerRegistration?
    private let cacheKey = "cached_chats_v2"     // 🗃️ new cache key

    // 🧠 Load chats (show cache first, then live Firestore)
    func listenToChats(for userId: String, pageSize: Int = 30) {
        // 1) ⚡ Instant UI: show whatever we saved last time
        loadCache()

        // 2) 🧹 clean old listener
        listener?.remove()

        // 3) 📡 live listener from Firestore (limited + newest first)
        listener = Firestore.firestore()
            .collection("chats")
            .whereField("participants", arrayContains: userId)
            .order(by: "timeStamp", descending: true)
            .limit(to: pageSize)                            // ⛔ limit here
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    self.errorMessage = "❌ Listener failed: \(error.localizedDescription)"
                    return
                }
                guard let docs = snapshot?.documents else {
                    self.errorMessage = "❌ No chat documents found"
                    return
                }

                // 4) 🔄 Firestore → ChatModel
                self.chats = docs.compactMap { ChatModel(id: $0.documentID, data: $0.data()) }

                // 5) 💾 Save to cache for next app open
                self.saveCache(self.chats)

                print("📡 Live chat list updated with \(self.chats.count) chats")
            }
    }

    deinit { listener?.remove() }

    // MARK: - CACHE WRITE
    private func saveCache(_ items: [ChatModel]) {
        do {
            let data = try JSONEncoder().encode(items)     // ChatModel is Codable now
            UserDefaults.standard.set(data, forKey: cacheKey)
        } catch {
            print("⚠️ Cache save failed: \(error.localizedDescription)")
        }
    }

    // MARK: - CACHE READ
    private func loadCache() {
        guard let data = UserDefaults.standard.data(forKey: cacheKey) else { return }
        do {
            let cached = try JSONDecoder().decode([ChatModel].self, from: data)
            self.chats = cached
            print("🗃️ Loaded \(cached.count) chats from cache")
        } catch {
            print("⚠️ Cache load failed: \(error.localizedDescription)")
        }
    }
}
