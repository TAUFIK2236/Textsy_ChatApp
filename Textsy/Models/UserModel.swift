struct UserModel {
    var name: String
    var age: Int
    var location: String
    var bio: String
    var profileImageUrl: String?

    init(_ data: [String: Any]) {
        self.name = data["name"] as? String ?? ""
        self.age = data["age"] as? Int ?? 0
        self.location = data["location"] as? String ?? ""
        self.bio = data["bio"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String
    }
}
