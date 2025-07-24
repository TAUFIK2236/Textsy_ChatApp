struct ChatRequest: Identifiable {
    var id: String
    var name: String
    var bio: String
    var profileImageUrl: String?
    var timestamp: Date?

    init(_ data: [String: Any], id: String) {
        self.id = id
        self.name = data["name"] as? String ?? ""
        self.bio = data["bio"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String
        self.timestamp = (data["timestamp"] as? Timestamp)?.dateValue()
    }
}
