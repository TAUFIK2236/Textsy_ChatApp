
//this one foe home page

import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class ChatViewModel: ObservableObject {
    @Published var chats: [ChatModel] = []
    @Published var errorMessage = ""
    
    private var listener: ListenerRegistration?
    private let cacheKey = "cached_chats_v2"
    
    // 🧠 Load chats from Firestore
    func listenToChats(for userId: String,pageSize : Int = 30) {
        
        loadCache()
        listener?.remove()
        
        listener = Firestore.firestore()
            .collection("chats")
            .whereField("participants", arrayContains: userId)
            .order(by: "timeStamp", descending: true)
            .limit(to:pageSize)
            .addSnapshotListener {[weak self] snapshot, error in
                guard let self = self else {return}
                if let error = error {
                    self.errorMessage = "❌ Listener failed: \(error.localizedDescription)"
                    return
                }
                
                guard let docs = snapshot?.documents else {
                    self.errorMessage = "❌ No chat documents found"
                    return
                }
                
                self.chats = docs.compactMap {
                    ChatModel(id: $0.documentID, data: $0.data())
                }
                self.saveCache(self.chats)
                
                print("📡 Live chat list updated with \(self.chats.count) chats")
            }
    }
    
    private func saveCache(_ items: [ChatModel]){
        do{
            let data = try JSONEncoder().encode(items)
            UserDefaults.standard.set(data, forKey: cacheKey)
        }catch{
            print("Cache save failed : \(error.localizedDescription)")
        }
    }
    
    
    private func loadCache(){
        guard let data = UserDefaults.standard.data(forKey: cacheKey) else {return}
        do{
            let cached = try JSONDecoder().decode([ChatModel].self, from: data)
            self.chats = cached
            print("Load\(cached.count) chats from cache")
        }catch{
            print("Cache load failed : \(error.localizedDescription)")
        }
    }
    
}
