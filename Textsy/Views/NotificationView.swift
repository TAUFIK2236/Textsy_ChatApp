import SwiftUI

struct NotificationView: View {
    // Sample requests for UI demo
    let requests: [MockRequest] = [
        MockRequest(
            id: "u1",
            name: "Anika",
            age: 21,
            location: "Brooklyn, NY",
            bio: "Designer • Coffee lover",
            profileImageUrl: nil
        ),
        MockRequest(
            id: "u2",
            name: "Samir",
            age: 25,
            location: "Queens, NY",
            bio: "Traveler • Code ninja",
            profileImageUrl: nil
        )
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 15) {
                    ForEach(requests) { request in
                        HStack(spacing: 12) {
                            // Profile Image
                            profileImage(for: request)
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())

                            // Name & Subtitle
                            VStack(alignment: .leading, spacing: 4) {
                                Text(request.name)
                                    .foregroundColor(.white)
                                    .font(.body.bold())

                                Text("requested to chat.")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }

                            Spacer()

                            // Confirm Button
                            Button("Accept") {
                                // Placeholder action
                            }
                            .font(.body.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue)
                            .cornerRadius(8)

                            // Delete Button
                            Button("Decline") {
                                // Placeholder action
                            }
                           // .foregroundColor(.white.opacity(0.7))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red)
                            .cornerRadius(8)

                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color(.fieldT))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .background(Color(.bgc))
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Profile Image
    private func profileImage(for request: MockRequest) -> some View {
        if let urlStr = request.profileImageUrl,
           let url = URL(string: urlStr),
           !urlStr.isEmpty {
            return AnyView(
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Image("Profile")
                        .resizable().scaledToFill()
                }
            )
        } else {
            return AnyView(
                Image("profile")
                    .resizable().scaledToFill()
            )
        }
    }
}

// MARK: - Preview
#Preview("Notification View – Clean") {
    NotificationView()
        .preferredColorScheme(.light)
}

// MARK: - Mock Data Model
struct MockRequest: Identifiable {
    let id: String
    let name: String
    let age: Int
    let location: String
    let bio: String
    let profileImageUrl: String?
}
